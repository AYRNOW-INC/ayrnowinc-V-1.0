package com.ayrnow.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SignatureResponse {
    private Long id;
    private Long signerId;
    private String signerName;
    private String signerRole;
    private boolean signed;
    private String signedAt;
}
