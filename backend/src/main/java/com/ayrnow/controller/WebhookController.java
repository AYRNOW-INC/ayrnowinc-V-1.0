package com.ayrnow.controller;

import com.ayrnow.service.PaymentService;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.model.Event;
import com.stripe.model.checkout.Session;
import com.stripe.net.Webhook;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/webhooks")
@RequiredArgsConstructor
@Slf4j
public class WebhookController {

    private final PaymentService paymentService;

    @Value("${stripe.webhook-secret}")
    private String webhookSecret;

    @PostMapping("/stripe")
    public ResponseEntity<String> handleStripeWebhook(
            @RequestBody String payload,
            @RequestHeader("Stripe-Signature") String sigHeader) {
        try {
            Event event = Webhook.constructEvent(payload, sigHeader, webhookSecret);
            String eventId = event.getId();

            log.info("Received Stripe webhook: type={}, id={}", event.getType(), eventId);

            switch (event.getType()) {
                case "checkout.session.completed" -> {
                    Session session = (Session) event.getDataObjectDeserializer()
                            .getObject().orElse(null);
                    if (session != null) {
                        log.info("Checkout session completed: {}", session.getId());
                        paymentService.handleWebhookPaymentSuccess(session.getId(), eventId);
                    }
                }
                case "checkout.session.expired" -> {
                    Session session = (Session) event.getDataObjectDeserializer()
                            .getObject().orElse(null);
                    if (session != null) {
                        log.info("Checkout session expired: {}", session.getId());
                        paymentService.handleWebhookSessionExpired(session.getId(), eventId);
                    }
                }
                case "checkout.session.async_payment_failed" -> {
                    Session session = (Session) event.getDataObjectDeserializer()
                            .getObject().orElse(null);
                    if (session != null) {
                        log.info("Async payment failed: {}", session.getId());
                        paymentService.handleWebhookPaymentFailed(session.getId(), eventId);
                    }
                }
                default -> log.info("Unhandled Stripe event type: {}", event.getType());
            }

            return ResponseEntity.ok("OK");
        } catch (SignatureVerificationException e) {
            log.error("Invalid Stripe webhook signature", e);
            return ResponseEntity.badRequest().body("Invalid signature");
        } catch (Exception e) {
            log.error("Error processing Stripe webhook", e);
            return ResponseEntity.status(500).body("Internal error");
        }
    }
}
