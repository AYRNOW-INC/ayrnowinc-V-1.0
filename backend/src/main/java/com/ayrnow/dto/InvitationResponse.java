package com.ayrnow.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class InvitationResponse {
    private Long id;
    private Long unitSpaceId;
    private String unitName;
    private String propertyName;
    private String tenantEmail;
    private String tenantPhone;
    private String inviteCode;
    private String status;
    private String expiresAt;
    private String tenantName;
}
