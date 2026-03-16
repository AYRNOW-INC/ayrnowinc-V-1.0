package com.ayrnow.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "lease_settings")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class LeaseSettings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false, unique = true)
    private Property property;

    @Column(name = "default_lease_term_months")
    @Builder.Default
    private Integer defaultLeaseTermMonths = 12;

    @Column(name = "default_monthly_rent")
    private BigDecimal defaultMonthlyRent;

    @Column(name = "default_security_deposit")
    private BigDecimal defaultSecurityDeposit;

    @Column(name = "payment_due_day")
    @Builder.Default
    private Integer paymentDueDay = 1;

    @Column(name = "grace_period_days")
    @Builder.Default
    private Integer gracePeriodDays = 5;

    @Column(name = "late_fee_amount")
    @Builder.Default
    private BigDecimal lateFeeAmount = BigDecimal.ZERO;

    @Column(name = "late_fee_type")
    @Builder.Default
    private String lateFeeType = "FLAT";

    @Column(name = "special_terms")
    private String specialTerms;

    @Column(name = "created_at", nullable = false, updatable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private LocalDateTime updatedAt = LocalDateTime.now();

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
