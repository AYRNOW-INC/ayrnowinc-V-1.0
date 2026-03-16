package com.ayrnow.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class LeaseRequest {
    @NotNull
    private Long propertyId;
    @NotNull
    private Long unitSpaceId;
    @NotNull
    private Long tenantId;
    @NotNull
    private Integer leaseTermMonths;
    @NotNull
    private BigDecimal monthlyRent;
    private BigDecimal securityDeposit;
    @NotNull
    private LocalDate startDate;
    private Integer paymentDueDay;
    private Integer gracePeriodDays;
    private BigDecimal lateFeeAmount;
    private String lateFeeType;
    private String specialTerms;
}
