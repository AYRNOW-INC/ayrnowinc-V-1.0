package com.ayrnow.controller;

import com.ayrnow.dto.LeaseRequest;
import com.ayrnow.dto.LeaseResponse;
import com.ayrnow.service.LeaseService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/leases")
@RequiredArgsConstructor
public class LeaseController {

    private final LeaseService leaseService;

    @PostMapping
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<LeaseResponse> create(Authentication auth,
                                                 @Valid @RequestBody LeaseRequest request) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(leaseService.createLease(userId, request));
    }

    @GetMapping("/landlord")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<List<LeaseResponse>> getLandlordLeases(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(leaseService.getLeasesByLandlord(userId));
    }

    @GetMapping("/tenant")
    @PreAuthorize("hasRole('TENANT')")
    public ResponseEntity<List<LeaseResponse>> getTenantLeases(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(leaseService.getLeasesByTenant(userId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<LeaseResponse> getOne(Authentication auth, @PathVariable Long id) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(leaseService.getLease(id, userId));
    }

    @PostMapping("/{id}/send")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<LeaseResponse> sendForSigning(Authentication auth, @PathVariable Long id) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(leaseService.sendForSigning(id, userId));
    }

    @PostMapping("/{id}/sign")
    public ResponseEntity<LeaseResponse> sign(Authentication auth, @PathVariable Long id,
                                               HttpServletRequest request) {
        Long userId = (Long) auth.getPrincipal();
        String ip = request.getRemoteAddr();
        return ResponseEntity.ok(leaseService.signLease(id, userId, ip));
    }
}
