package com.ayrnow.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class PaymentResponse {
    private Long id;
    private Long tenantId;
    private Long leaseId;
    private Long propertyId;
    private String propertyName;
    private Long unitSpaceId;
    private String unitName;
    private BigDecimal amount;
    private String paymentType;
    private String status;
    private String dueDate;
    private String paidAt;
}
