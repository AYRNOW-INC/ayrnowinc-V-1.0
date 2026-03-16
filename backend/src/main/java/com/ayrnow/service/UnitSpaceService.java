package com.ayrnow.service;

import com.ayrnow.dto.UnitSpaceRequest;
import com.ayrnow.dto.UnitSpaceResponse;
import com.ayrnow.entity.*;
import com.ayrnow.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UnitSpaceService {

    private final UnitSpaceRepository unitSpaceRepository;
    private final PropertyRepository propertyRepository;

    @Transactional
    public UnitSpaceResponse createUnit(Long propertyId, Long userId, UnitSpaceRequest request) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        if (!property.getLandlord().getId().equals(userId)) {
            throw new IllegalArgumentException("Access denied");
        }

        UnitSpace unit = UnitSpace.builder()
                .property(property)
                .name(request.getName())
                .unitType(UnitType.valueOf(request.getUnitType().toUpperCase()))
                .floor(request.getFloor())
                .bedrooms(request.getBedrooms())
                .bathrooms(request.getBathrooms())
                .squareFeet(request.getSquareFeet())
                .monthlyRent(request.getMonthlyRent())
                .description(request.getDescription())
                .build();
        unit = unitSpaceRepository.save(unit);
        return toResponse(unit);
    }

    public List<UnitSpaceResponse> getUnitsByProperty(Long propertyId, Long userId) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        if (!property.getLandlord().getId().equals(userId)) {
            throw new IllegalArgumentException("Access denied");
        }
        return unitSpaceRepository.findByPropertyIdOrderByName(propertyId).stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public UnitSpaceResponse updateUnit(Long unitId, Long userId, UnitSpaceRequest request) {
        UnitSpace unit = unitSpaceRepository.findById(unitId)
                .orElseThrow(() -> new IllegalArgumentException("Unit not found"));
        if (!unit.getProperty().getLandlord().getId().equals(userId)) {
            throw new IllegalArgumentException("Access denied");
        }
        if (request.getName() != null) unit.setName(request.getName());
        if (request.getUnitType() != null) unit.setUnitType(UnitType.valueOf(request.getUnitType().toUpperCase()));
        if (request.getFloor() != null) unit.setFloor(request.getFloor());
        if (request.getBedrooms() != null) unit.setBedrooms(request.getBedrooms());
        if (request.getBathrooms() != null) unit.setBathrooms(request.getBathrooms());
        if (request.getSquareFeet() != null) unit.setSquareFeet(request.getSquareFeet());
        if (request.getMonthlyRent() != null) unit.setMonthlyRent(request.getMonthlyRent());
        if (request.getDescription() != null) unit.setDescription(request.getDescription());
        unitSpaceRepository.save(unit);
        return toResponse(unit);
    }

    @Transactional
    public void deleteUnit(Long unitId, Long userId) {
        UnitSpace unit = unitSpaceRepository.findById(unitId)
                .orElseThrow(() -> new IllegalArgumentException("Unit not found"));
        if (!unit.getProperty().getLandlord().getId().equals(userId)) {
            throw new IllegalArgumentException("Access denied");
        }
        unitSpaceRepository.delete(unit);
    }

    private UnitSpaceResponse toResponse(UnitSpace u) {
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
}
