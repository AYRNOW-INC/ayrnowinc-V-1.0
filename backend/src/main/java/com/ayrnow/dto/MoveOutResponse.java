package com.ayrnow.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class MoveOutResponse {
    private Long id;
    private Long tenantId;
    private String tenantName;
    private Long leaseId;
    private String propertyName;
    private String unitName;
    private String requestedDate;
    private String reason;
    private String status;
    private String reviewComment;
    private String reviewedAt;
    private String createdAt;
}
