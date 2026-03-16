package com.ayrnow.controller;

import com.ayrnow.dto.PropertyRequest;
import com.ayrnow.dto.PropertyResponse;
import com.ayrnow.service.PropertyService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/properties")
@RequiredArgsConstructor
public class PropertyController {

    private final PropertyService propertyService;

    @PostMapping
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<PropertyResponse> create(Authentication auth,
                                                    @Valid @RequestBody PropertyRequest request) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(propertyService.createProperty(userId, request));
    }

    @GetMapping
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<List<PropertyResponse>> getAll(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(propertyService.getPropertiesByLandlord(userId));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<PropertyResponse> getOne(Authentication auth, @PathVariable Long id) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(propertyService.getProperty(id, userId));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<PropertyResponse> update(Authentication auth, @PathVariable Long id,
                                                    @Valid @RequestBody PropertyRequest request) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(propertyService.updateProperty(id, userId, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<Void> delete(Authentication auth, @PathVariable Long id) {
        Long userId = (Long) auth.getPrincipal();
        propertyService.deleteProperty(id, userId);
        return ResponseEntity.noContent().build();
    }
}
