package com.ayrnow.controller;

import com.ayrnow.dto.CheckoutResponse;
import com.ayrnow.dto.PaymentResponse;
import com.ayrnow.service.PaymentService;
import com.stripe.exception.StripeException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @GetMapping("/tenant")
    @PreAuthorize("hasRole('TENANT')")
    public ResponseEntity<List<PaymentResponse>> getTenantPayments(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(paymentService.getPaymentsByTenant(userId));
    }

    @GetMapping("/lease/{leaseId}")
    public ResponseEntity<List<PaymentResponse>> getLeasePayments(@PathVariable Long leaseId) {
        return ResponseEntity.ok(paymentService.getPaymentsByLease(leaseId));
    }

    @GetMapping("/property/{propertyId}")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<List<PaymentResponse>> getPropertyPayments(@PathVariable Long propertyId) {
        return ResponseEntity.ok(paymentService.getPaymentsByProperty(propertyId));
    }

    @PostMapping("/lease/{leaseId}/create")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<PaymentResponse> createPayment(@PathVariable Long leaseId) {
        return ResponseEntity.ok(paymentService.createPaymentForLease(leaseId));
    }

    @PostMapping("/{id}/checkout")
    @PreAuthorize("hasRole('TENANT')")
    public ResponseEntity<CheckoutResponse> checkout(Authentication auth,
                                                      @PathVariable Long id) throws StripeException {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(paymentService.createCheckoutSession(id, userId));
    }
}
