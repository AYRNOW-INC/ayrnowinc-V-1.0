package com.ayrnow.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
public class AuthResponse {
    private Long userId;
    private String email;
    private String firstName;
    private String lastName;
    private List<String> roles;
    private String accessToken;
    private String refreshToken;
}
