package com.ayrnow.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "leases")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Lease {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    private Property property;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "unit_space_id", nullable = false)
    private UnitSpace unitSpace;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "landlord_id", nullable = false)
    private User landlord;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tenant_id", nullable = false)
    private User tenant;

    @Column(name = "lease_term_months", nullable = false)
    private Integer leaseTermMonths;

    @Column(name = "monthly_rent", nullable = false)
    private BigDecimal monthlyRent;

    @Column(name = "security_deposit")
    private BigDecimal securityDeposit;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDate endDate;

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

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private LeaseStatus status = LeaseStatus.DRAFT;

    @Column(name = "document_url")
    private String documentUrl;

    @Column(name = "opensign_doc_id")
    private String opensignDocId;

    @OneToMany(mappedBy = "lease", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<LeaseSignature> signatures = new ArrayList<>();

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
