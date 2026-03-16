package com.ayrnow.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class InvitationRequest {
    @NotNull
    private Long unitSpaceId;
    private String tenantEmail;
    private String tenantPhone;
}
