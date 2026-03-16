package com.ayrnow.controller;

import com.ayrnow.dto.InvitationRequest;
import com.ayrnow.dto.InvitationResponse;
import com.ayrnow.service.InvitationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/invitations")
@RequiredArgsConstructor
public class InvitationController {

    private final InvitationService invitationService;

    @PostMapping
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<InvitationResponse> create(Authentication auth,
                                                      @Valid @RequestBody InvitationRequest request) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(invitationService.createInvitation(userId, request));
    }

    @GetMapping
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<List<InvitationResponse>> getAll(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(invitationService.getInvitationsByLandlord(userId));
    }

    @GetMapping("/accept/{code}")
    public ResponseEntity<InvitationResponse> getByCode(@PathVariable String code) {
        return ResponseEntity.ok(invitationService.getInvitationByCode(code));
    }

    @PostMapping("/accept/{code}")
    public ResponseEntity<InvitationResponse> accept(@PathVariable String code,
                                                      Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(invitationService.acceptInvitation(code, userId));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('LANDLORD')")
    public ResponseEntity<Void> cancel(Authentication auth, @PathVariable Long id) {
        Long userId = (Long) auth.getPrincipal();
        invitationService.cancelInvitation(id, userId);
        return ResponseEntity.noContent().build();
    }
}
