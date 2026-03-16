package com.ayrnow.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class PropertyResponse {
    private Long id;
    private String name;
    private String propertyType;
    private String address;
    private String city;
    private String state;
    private String postalCode;
    private String country;
    private String description;
    private String imageUrl;
    private String status;
    private int totalUnits;
    private int vacantUnits;
    private int occupiedUnits;
    private List<UnitSpaceResponse> unitSpaces;
    private LeaseSettingsResponse leaseSettings;
}
