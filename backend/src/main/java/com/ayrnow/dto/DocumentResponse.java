package com.ayrnow.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DocumentResponse {
    private Long id;
    private Long tenantId;
    private String tenantName;
    private Long leaseId;
    private String documentType;
    private String fileName;
    private String fileType;
    private Long fileSize;
    private String status;
    private String reviewComment;
    private String reviewedAt;
    private String createdAt;
}
