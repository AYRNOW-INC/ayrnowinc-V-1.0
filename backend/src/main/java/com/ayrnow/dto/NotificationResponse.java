package com.ayrnow.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class NotificationResponse {
    private Long id;
    private String title;
    private String message;
    private String type;
    private Long referenceId;
    private String referenceType;
    private boolean read;
    private String createdAt;
}
