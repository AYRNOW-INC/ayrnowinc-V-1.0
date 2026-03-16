package com.ayrnow.controller;

import com.ayrnow.dto.MoveOutRequestDto;
import com.ayrnow.dto.MoveOutResponse;
import com.ayrnow.dto.ReviewRequest;
import com.ayrnow.service.MoveOutService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/move-out")
@RequiredArgsConstructor
public class MoveOutController {

    private final MoveOutService moveOutService;

    @PostMapping
    @PreAuthorize("hasRole('TENANT')")
    public ResponseEntity<MoveOutResponse> create(Authentication auth,
                                                   @Valid @RequestBody MoveOutRequestDto request) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(moveOutService.createRequest(userId, request));
    }

    @GetMapping("/tenant")
    @PreAuthorize("hasRole('TENANT')")
    public ResponseEntity<List<MoveOutResponse>> getTenantRequests(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(moveOutService.getByTenant(userId));
    }

    @GetMapping("/landlord")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<List<MoveOutResponse>> getLandlordRequests(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(moveOutService.getByLandlord(userId));
    }

    @PutMapping("/{id}/review")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<MoveOutResponse> review(Authentication auth, @PathVariable Long id,
                                                   @Valid @RequestBody ReviewRequest request) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(moveOutService.reviewRequest(id, userId, request));
    }
}
