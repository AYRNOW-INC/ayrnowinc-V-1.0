package com.ayrnow.controller;

import com.ayrnow.dto.DashboardResponse;
import com.ayrnow.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/landlord")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<DashboardResponse> landlordDashboard(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(dashboardService.getLandlordDashboard(userId));
    }

    @GetMapping("/tenant")
    @PreAuthorize("hasRole('TENANT')")
    public ResponseEntity<DashboardResponse> tenantDashboard(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(dashboardService.getTenantDashboard(userId));
    }
}
