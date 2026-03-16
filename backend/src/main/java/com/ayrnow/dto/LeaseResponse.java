package com.ayrnow.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
public class LeaseResponse {
    private Long id;
    private Long propertyId;
    private String propertyName;
    private Long unitSpaceId;
    private String unitName;
    private Long landlordId;
    private String landlordName;
    private Long tenantId;
    private String tenantName;
    private Integer leaseTermMonths;
    private BigDecimal monthlyRent;
    private BigDecimal securityDeposit;
    private String startDate;
    private String endDate;
    private Integer paymentDueDay;
    private Integer gracePeriodDays;
    private BigDecimal lateFeeAmount;
    private String lateFeeType;
    private String specialTerms;
    private String status;
    private String documentUrl;
    private List<SignatureResponse> signatures;
}
