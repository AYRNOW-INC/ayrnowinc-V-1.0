package com.ayrnow.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "unit_spaces")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class UnitSpace {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    private Property property;

    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "unit_type", nullable = false)
    private UnitType unitType;

    private String floor;

    private Integer bedrooms;

    private BigDecimal bathrooms;

    @Column(name = "square_feet")
    private BigDecimal squareFeet;

    @Column(name = "monthly_rent")
    private BigDecimal monthlyRent;

    @Column(nullable = false)
    @Builder.Default
    private String status = "VACANT";

    private String description;

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
