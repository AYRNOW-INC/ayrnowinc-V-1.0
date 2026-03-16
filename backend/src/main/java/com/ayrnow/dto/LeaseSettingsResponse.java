package com.ayrnow.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class LeaseSettingsResponse {
    private Long id;
    private Long propertyId;
    private Integer defaultLeaseTermMonths;
    private BigDecimal defaultMonthlyRent;
    private BigDecimal defaultSecurityDeposit;
    private Integer paymentDueDay;
    private Integer gracePeriodDays;
    private BigDecimal lateFeeAmount;
    private String lateFeeType;
    private String specialTerms;
}
