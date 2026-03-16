package com.ayrnow.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDate;

@Data
public class MoveOutRequestDto {
    @NotNull
    private Long leaseId;
    @NotNull
    private LocalDate requestedDate;
    private String reason;
}
