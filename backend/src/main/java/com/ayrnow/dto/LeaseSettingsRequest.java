package com.ayrnow.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class LeaseSettingsRequest {
    private Integer defaultLeaseTermMonths;
    private BigDecimal defaultMonthlyRent;
    private BigDecimal defaultSecurityDeposit;
    private Integer paymentDueDay;
    private Integer gracePeriodDays;
    private BigDecimal lateFeeAmount;
    private String lateFeeType;
    private String specialTerms;
}
