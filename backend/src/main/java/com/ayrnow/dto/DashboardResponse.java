package com.ayrnow.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class DashboardResponse {
    // Landlord stats
    private Long totalProperties;
    private Long totalUnits;
    private Long occupiedUnits;
    private Long vacantUnits;
    private Long activeLeases;
    private Long pendingInvitations;
    private Long pendingMoveOuts;
    private BigDecimal totalRevenue;

    // Tenant stats
    private BigDecimal amountDue;
    private String nextDueDate;
    private String leaseStatus;
    private String propertyName;
    private String unitName;
}
