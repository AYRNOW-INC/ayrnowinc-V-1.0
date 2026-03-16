package com.ayrnow.controller;

import com.ayrnow.dto.LeaseSettingsRequest;
import com.ayrnow.dto.LeaseSettingsResponse;
import com.ayrnow.service.LeaseSettingsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/properties/{propertyId}/lease-settings")
@RequiredArgsConstructor
public class LeaseSettingsController {

    private final LeaseSettingsService leaseSettingsService;

    @GetMapping
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<LeaseSettingsResponse> get(Authentication auth,
                                                      @PathVariable Long propertyId) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(leaseSettingsService.getByProperty(propertyId, userId));
    }

    @PutMapping
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<LeaseSettingsResponse> update(Authentication auth,
                                                         @PathVariable Long propertyId,
                                                         @RequestBody LeaseSettingsRequest request) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(leaseSettingsService.update(propertyId, userId, request));
    }
}
