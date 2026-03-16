package com.ayrnow.repository;

import com.ayrnow.entity.Payment;
import com.ayrnow.entity.PaymentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
    List<Payment> findByTenantIdOrderByDueDateDesc(Long tenantId);
    List<Payment> findByLeaseIdOrderByDueDateDesc(Long leaseId);
    List<Payment> findByPropertyIdOrderByDueDateDesc(Long propertyId);
    Optional<Payment> findByStripePaymentIntentId(String stripePaymentIntentId);
    Optional<Payment> findByStripeCheckoutSessionId(String sessionId);
    Optional<Payment> findByStripeEventId(String stripeEventId);
    List<Payment> findByTenantIdAndStatus(Long tenantId, PaymentStatus status);
    long countByTenantIdAndStatus(Long tenantId, PaymentStatus status);

    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.lease.landlord.id = :landlordId AND p.status = 'SUCCESSFUL'")
    BigDecimal sumSuccessfulPaymentsByLandlordId(Long landlordId);
}
