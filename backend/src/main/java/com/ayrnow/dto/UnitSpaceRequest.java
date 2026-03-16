package com.ayrnow.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class UnitSpaceRequest {
    @NotBlank
    private String name;
    @NotNull
    private String unitType;
    private String floor;
    private Integer bedrooms;
    private BigDecimal bathrooms;
    private BigDecimal squareFeet;
    private BigDecimal monthlyRent;
    private String description;
}
