package com.ayrnow.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class UnitSpaceResponse {
    private Long id;
    private Long propertyId;
    private String name;
    private String unitType;
    private String floor;
    private Integer bedrooms;
    private BigDecimal bathrooms;
    private BigDecimal squareFeet;
    private BigDecimal monthlyRent;
    private String status;
    private String description;

    // Lifecycle enrichment fields
    private String invitationStatus;  // null, PENDING, SENT, ACCEPTED, etc.
    private String leaseStatus;       // null, DRAFT, SENT_FOR_SIGNING, FULLY_EXECUTED, etc.
    private Long activeLeaseId;       // For deep-link to lease
    private String tenantName;        // If tenant is assigned
    private String workflowStep;      // Computed: SETUP, INVITE, LEASE, SIGN, ACTIVE
}
