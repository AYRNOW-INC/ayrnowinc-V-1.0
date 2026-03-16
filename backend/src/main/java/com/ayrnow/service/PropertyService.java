package com.ayrnow.service;

import com.ayrnow.dto.*;
import com.ayrnow.entity.*;
import com.ayrnow.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PropertyService {

    private final PropertyRepository propertyRepository;
    private final UnitSpaceRepository unitSpaceRepository;
    private final UserRepository userRepository;
    private final LeaseSettingsRepository leaseSettingsRepository;

    @Transactional
    public PropertyResponse createProperty(Long landlordId, PropertyRequest request) {
        User landlord = userRepository.findById(landlordId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Property property = Property.builder()
                .landlord(landlord)
                .name(request.getName())
                .propertyType(PropertyType.valueOf(request.getPropertyType().toUpperCase()))
                .address(request.getAddress())
                .city(request.getCity())
                .state(request.getState())
                .postalCode(request.getPostalCode())
                .country(request.getCountry() != null ? request.getCountry() : "US")
                .description(request.getDescription())
                .build();
        property = propertyRepository.save(property);

        // Create default lease settings
        LeaseSettings settings = LeaseSettings.builder().property(property).build();
        leaseSettingsRepository.save(settings);

        // Create initial units if specified
        if (request.getInitialUnitCount() != null && request.getInitialUnitCount() > 0) {
            UnitType defaultType = getDefaultUnitType(property.getPropertyType());
            String prefix = getUnitPrefix(property.getPropertyType());
            for (int i = 1; i <= request.getInitialUnitCount(); i++) {
                UnitSpace unit = UnitSpace.builder()
                        .property(property)
                        .name(prefix + " " + i)
                        .unitType(defaultType)
                        .build();
                unitSpaceRepository.save(unit);
            }
        }

        return toResponse(property);
    }

    public List<PropertyResponse> getPropertiesByLandlord(Long landlordId) {
        return propertyRepository.findByLandlordIdOrderByCreatedAtDesc(landlordId).stream()
                .map(this::toResponse)
                .toList();
    }

    public PropertyResponse getProperty(Long propertyId, Long userId) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        if (!property.getLandlord().getId().equals(userId)) {
            throw new IllegalArgumentException("Access denied");
        }
        return toResponse(property);
    }

    @Transactional
    public PropertyResponse updateProperty(Long propertyId, Long userId, PropertyRequest request) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        if (!property.getLandlord().getId().equals(userId)) {
            throw new IllegalArgumentException("Access denied");
        }
        if (request.getName() != null) property.setName(request.getName());
        if (request.getAddress() != null) property.setAddress(request.getAddress());
        if (request.getCity() != null) property.setCity(request.getCity());
        if (request.getState() != null) property.setState(request.getState());
        if (request.getPostalCode() != null) property.setPostalCode(request.getPostalCode());
        if (request.getDescription() != null) property.setDescription(request.getDescription());
        propertyRepository.save(property);
        return toResponse(property);
    }

    @Transactional
    public void deleteProperty(Long propertyId, Long userId) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        if (!property.getLandlord().getId().equals(userId)) {
            throw new IllegalArgumentException("Access denied");
        }
        propertyRepository.delete(property);
    }

    private PropertyResponse toResponse(Property p) {
        List<UnitSpace> units = unitSpaceRepository.findByPropertyIdOrderByName(p.getId());
        long vacant = units.stream().filter(u -> "VACANT".equals(u.getStatus())).count();
        long occupied = units.stream().filter(u -> "OCCUPIED".equals(u.getStatus())).count();

        LeaseSettingsResponse lsResponse = null;
        leaseSettingsRepository.findByPropertyId(p.getId()).ifPresent(ls -> {});
        var lsOpt = leaseSettingsRepository.findByPropertyId(p.getId());
        if (lsOpt.isPresent()) {
            LeaseSettings ls = lsOpt.get();
            lsResponse = LeaseSettingsResponse.builder()
                    .id(ls.getId())
                    .propertyId(p.getId())
                    .defaultLeaseTermMonths(ls.getDefaultLeaseTermMonths())
                    .defaultMonthlyRent(ls.getDefaultMonthlyRent())
                    .defaultSecurityDeposit(ls.getDefaultSecurityDeposit())
                    .paymentDueDay(ls.getPaymentDueDay())
                    .gracePeriodDays(ls.getGracePeriodDays())
                    .lateFeeAmount(ls.getLateFeeAmount())
                    .lateFeeType(ls.getLateFeeType())
                    .specialTerms(ls.getSpecialTerms())
                    .build();
        }

        return PropertyResponse.builder()
                .id(p.getId())
                .name(p.getName())
                .propertyType(p.getPropertyType().name())
                .address(p.getAddress())
                .city(p.getCity())
                .state(p.getState())
                .postalCode(p.getPostalCode())
                .country(p.getCountry())
                .description(p.getDescription())
                .imageUrl(p.getImageUrl())
                .status(p.getStatus())
                .totalUnits(units.size())
                .vacantUnits((int) vacant)
                .occupiedUnits((int) occupied)
                .unitSpaces(units.stream().map(this::toUnitResponse).toList())
                .leaseSettings(lsResponse)
                .build();
    }

    private UnitSpaceResponse toUnitResponse(UnitSpace u) {
        return UnitSpaceResponse.builder()
                .id(u.getId())
                .propertyId(u.getProperty().getId())
                .name(u.getName())
                .unitType(u.getUnitType().name())
                .floor(u.getFloor())
                .bedrooms(u.getBedrooms())
                .bathrooms(u.getBathrooms())
                .squareFeet(u.getSquareFeet())
                .monthlyRent(u.getMonthlyRent())
                .status(u.getStatus())
                .description(u.getDescription())
                .build();
    }

    private UnitType getDefaultUnitType(PropertyType pt) {
        return switch (pt) {
            case RESIDENTIAL -> UnitType.APARTMENT;
            case COMMERCIAL -> UnitType.STORE;
            case OTHER -> UnitType.OTHER;
        };
    }

    private String getUnitPrefix(PropertyType pt) {
        return switch (pt) {
            case RESIDENTIAL -> "Unit";
            case COMMERCIAL -> "Space";
            case OTHER -> "Block";
        };
    }
}
