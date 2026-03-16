package com.ayrnow.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class PropertyRequest {
    @NotBlank
    private String name;
    @NotNull
    private String propertyType;
    @NotBlank
    private String address;
    @NotBlank
    private String city;
    @NotBlank
    private String state;
    @NotBlank
    private String postalCode;
    private String country;
    private String description;
    private Integer initialUnitCount;
}
