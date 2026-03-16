package com.ayrnow.controller;

import com.ayrnow.dto.UnitSpaceRequest;
import com.ayrnow.dto.UnitSpaceResponse;
import com.ayrnow.service.UnitSpaceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/properties/{propertyId}/units")
@RequiredArgsConstructor
public class UnitSpaceController {

    private final UnitSpaceService unitSpaceService;

    @PostMapping
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<UnitSpaceResponse> create(Authentication auth,
                                                     @PathVariable Long propertyId,
                                                     @Valid @RequestBody UnitSpaceRequest request) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(unitSpaceService.createUnit(propertyId, userId, request));
    }

    @GetMapping
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<List<UnitSpaceResponse>> getAll(Authentication auth,
                                                           @PathVariable Long propertyId) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(unitSpaceService.getUnitsByProperty(propertyId, userId));
    }

    @PutMapping("/{unitId}")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<UnitSpaceResponse> update(Authentication auth,
                                                     @PathVariable Long propertyId,
                                                     @PathVariable Long unitId,
                                                     @Valid @RequestBody UnitSpaceRequest request) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(unitSpaceService.updateUnit(unitId, userId, request));
    }

    @DeleteMapping("/{unitId}")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<Void> delete(Authentication auth,
                                        @PathVariable Long propertyId,
                                        @PathVariable Long unitId) {
        Long userId = (Long) auth.getPrincipal();
        unitSpaceService.deleteUnit(unitId, userId);
        return ResponseEntity.noContent().build();
    }
}
