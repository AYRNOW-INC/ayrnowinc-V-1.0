package com.ayrnow.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class UnitSpaceResponse {
    private Long id;
    private Long propertyId;
    private String name;
    private String unitType;
    private String floor;
    private Integer bedrooms;
    private BigDecimal bathrooms;
    private BigDecimal squareFeet;
    private BigDecimal monthlyRent;
    private String status;
    private String description;
}
