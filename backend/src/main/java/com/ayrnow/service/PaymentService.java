package com.ayrnow.service;

import com.ayrnow.dto.CheckoutResponse;
import com.ayrnow.dto.PaymentResponse;
import com.ayrnow.entity.*;
import com.ayrnow.repository.*;
import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final LeaseRepository leaseRepository;
    private final NotificationService notificationService;

    @Value("${stripe.secret-key}")
    private String stripeSecretKey;

    @Value("${stripe.success-url}")
    private String successUrl;

    @Value("${stripe.cancel-url}")
    private String cancelUrl;

    @PostConstruct
    public void init() {
        Stripe.apiKey = stripeSecretKey;
    }

    public List<PaymentResponse> getPaymentsByTenant(Long tenantId) {
        return paymentRepository.findByTenantIdOrderByDueDateDesc(tenantId).stream()
                .map(this::toResponse).toList();
    }

    public List<PaymentResponse> getPaymentsByLease(Long leaseId) {
        return paymentRepository.findByLeaseIdOrderByDueDateDesc(leaseId).stream()
                .map(this::toResponse).toList();
    }

    public List<PaymentResponse> getPaymentsByProperty(Long propertyId) {
        return paymentRepository.findByPropertyIdOrderByDueDateDesc(propertyId).stream()
                .map(this::toResponse).toList();
    }

    /**
     * Creates a rent payment record when a lease becomes fully executed.
     * Called by LeaseService after both parties sign.
     */
    @Transactional
    public PaymentResponse createPaymentForLease(Long leaseId) {
        Lease lease = leaseRepository.findById(leaseId)
                .orElseThrow(() -> new IllegalArgumentException("Lease not found"));

        Payment payment = Payment.builder()
                .tenant(lease.getTenant())
                .lease(lease)
                .property(lease.getProperty())
                .unitSpace(lease.getUnitSpace())
                .amount(lease.getMonthlyRent())
                .paymentType("RENT")
                .currency("usd")
                .dueDate(lease.getStartDate().withDayOfMonth(
                        lease.getPaymentDueDay() != null ? lease.getPaymentDueDay() : 1))
                .description("Rent for " + lease.getUnitSpace().getName() + " at " + lease.getProperty().getName())
                .build();
        payment = paymentRepository.save(payment);
        log.info("Created payment {} for lease {} amount ${}", payment.getId(), leaseId, lease.getMonthlyRent());
        return toResponse(payment);
    }

    /**
     * Creates a Stripe Checkout session for a pending payment.
     * Stores the session ID for webhook reconciliation.
     */
    @Transactional
    public CheckoutResponse createCheckoutSession(Long paymentId, Long tenantId) throws StripeException {
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new IllegalArgumentException("Payment not found"));
        if (!payment.getTenant().getId().equals(tenantId)) {
            throw new IllegalArgumentException("Access denied");
        }
        if (payment.getStatus() == PaymentStatus.SUCCESSFUL) {
            throw new IllegalArgumentException("Payment already completed");
        }

        long amountInCents = payment.getAmount().multiply(BigDecimal.valueOf(100)).longValue();

        SessionCreateParams params = SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.PAYMENT)
                .setSuccessUrl(successUrl + "?session_id={CHECKOUT_SESSION_ID}")
                .setCancelUrl(cancelUrl)
                .addLineItem(SessionCreateParams.LineItem.builder()
                        .setQuantity(1L)
                        .setPriceData(SessionCreateParams.LineItem.PriceData.builder()
                                .setCurrency(payment.getCurrency() != null ? payment.getCurrency() : "usd")
                                .setUnitAmount(amountInCents)
                                .setProductData(SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                        .setName(payment.getPaymentType() + " - " + payment.getUnitSpace().getName())
                                        .setDescription(payment.getDescription() != null ? payment.getDescription()
                                                : "Payment for " + payment.getProperty().getName())
                                        .build())
                                .build())
                        .build())
                .putMetadata("payment_id", payment.getId().toString())
                .putMetadata("lease_id", payment.getLease().getId().toString())
                .putMetadata("tenant_id", payment.getTenant().getId().toString())
                .build();

        Session session = Session.create(params);

        payment.setStripeCheckoutSessionId(session.getId());
        if (session.getPaymentIntent() != null) {
            payment.setStripePaymentIntentId(session.getPaymentIntent());
        }
        paymentRepository.save(payment);

        log.info("Created Stripe checkout session {} for payment {}", session.getId(), paymentId);

        return CheckoutResponse.builder()
                .checkoutUrl(session.getUrl())
                .sessionId(session.getId())
                .build();
    }

    /**
     * Handles checkout.session.completed webhook.
     * Idempotent: safe for duplicate delivery via stripe_event_id check.
     */
    @Transactional
    public void handleWebhookPaymentSuccess(String sessionId, String eventId) {
        if (eventId != null) {
            Optional<Payment> existing = paymentRepository.findByStripeEventId(eventId);
            if (existing.isPresent()) {
                log.info("Skipping duplicate webhook event {}", eventId);
                return;
            }
        }

        paymentRepository.findByStripeCheckoutSessionId(sessionId).ifPresent(payment -> {
            if (payment.getStatus() == PaymentStatus.SUCCESSFUL) {
                log.info("Payment {} already successful, skipping", payment.getId());
                return;
            }

            payment.setStatus(PaymentStatus.SUCCESSFUL);
            payment.setPaidAt(LocalDateTime.now());
            if (eventId != null) payment.setStripeEventId(eventId);
            paymentRepository.save(payment);

            log.info("Payment {} marked SUCCESSFUL via webhook event {}", payment.getId(), eventId);

            notificationService.createNotification(payment.getLease().getLandlord().getId(),
                    "Payment Received",
                    "Payment of $" + payment.getAmount() + " received for " + payment.getUnitSpace().getName(),
                    "PAYMENT", payment.getId(), "PAYMENT");

            notificationService.createNotification(payment.getTenant().getId(),
                    "Payment Confirmed",
                    "Your payment of $" + payment.getAmount() + " has been confirmed",
                    "PAYMENT", payment.getId(), "PAYMENT");
        });
    }

    /**
     * Handles payment failure webhook. Idempotent.
     */
    @Transactional
    public void handleWebhookPaymentFailed(String sessionId, String eventId) {
        if (eventId != null && paymentRepository.findByStripeEventId(eventId).isPresent()) {
            return;
        }

        paymentRepository.findByStripeCheckoutSessionId(sessionId).ifPresent(payment -> {
            payment.setStatus(PaymentStatus.FAILED);
            if (eventId != null) payment.setStripeEventId(eventId);
            paymentRepository.save(payment);

            log.info("Payment {} marked FAILED via webhook event {}", payment.getId(), eventId);

            notificationService.createNotification(payment.getTenant().getId(),
                    "Payment Failed",
                    "Your payment of $" + payment.getAmount() + " has failed. Please try again.",
                    "PAYMENT", payment.getId(), "PAYMENT");
        });
    }

    /**
     * Handles session expiration. Resets checkout session so tenant can retry.
     */
    @Transactional
    public void handleWebhookSessionExpired(String sessionId, String eventId) {
        if (eventId != null && paymentRepository.findByStripeEventId(eventId).isPresent()) {
            return;
        }

        paymentRepository.findByStripeCheckoutSessionId(sessionId).ifPresent(payment -> {
            if (payment.getStatus() != PaymentStatus.SUCCESSFUL) {
                payment.setStripeCheckoutSessionId(null);
                if (eventId != null) payment.setStripeEventId(eventId);
                paymentRepository.save(payment);
                log.info("Checkout session expired for payment {}, reset for retry", payment.getId());
            }
        });
    }

    private PaymentResponse toResponse(Payment p) {
        return PaymentResponse.builder()
                .id(p.getId())
                .tenantId(p.getTenant().getId())
                .leaseId(p.getLease().getId())
                .propertyId(p.getProperty().getId())
                .propertyName(p.getProperty().getName())
                .unitSpaceId(p.getUnitSpace().getId())
                .unitName(p.getUnitSpace().getName())
                .amount(p.getAmount())
                .paymentType(p.getPaymentType())
                .status(p.getStatus().name())
                .dueDate(p.getDueDate().toString())
                .paidAt(p.getPaidAt() != null ? p.getPaidAt().toString() : null)
                .build();
    }
}
