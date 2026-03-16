package com.ayrnow.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ReviewRequest {
    @NotBlank
    private String status; // APPROVED or REJECTED
    private String comment;
}
