package com.ayrnow.service;

import com.ayrnow.dto.InvitationRequest;
import com.ayrnow.dto.InvitationResponse;
import com.ayrnow.entity.*;
import com.ayrnow.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class InvitationService {

    private final InvitationRepository invitationRepository;
    private final UnitSpaceRepository unitSpaceRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    @Transactional
    public InvitationResponse createInvitation(Long landlordId, InvitationRequest request) {
        User landlord = userRepository.findById(landlordId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        UnitSpace unit = unitSpaceRepository.findById(request.getUnitSpaceId())
                .orElseThrow(() -> new IllegalArgumentException("Unit not found"));
        if (!unit.getProperty().getLandlord().getId().equals(landlordId)) {
            throw new IllegalArgumentException("Access denied");
        }

        String code = UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        Invitation inv = Invitation.builder()
                .landlord(landlord)
                .unitSpace(unit)
                .tenantEmail(request.getTenantEmail())
                .tenantPhone(request.getTenantPhone())
                .inviteCode(code)
                .status(InvitationStatus.SENT)
                .expiresAt(LocalDateTime.now().plusDays(7))
                .build();
        inv = invitationRepository.save(inv);
        return toResponse(inv);
    }

    public List<InvitationResponse> getInvitationsByLandlord(Long landlordId) {
        return invitationRepository.findByLandlordIdOrderByCreatedAtDesc(landlordId).stream()
                .map(this::toResponse)
                .toList();
    }

    public InvitationResponse getInvitationByCode(String code) {
        Invitation inv = invitationRepository.findByInviteCode(code)
                .orElseThrow(() -> new IllegalArgumentException("Invalid invite code"));
        if (inv.getExpiresAt().isBefore(LocalDateTime.now()) && inv.getStatus() != InvitationStatus.ACCEPTED) {
            inv.setStatus(InvitationStatus.EXPIRED);
            invitationRepository.save(inv);
        }
        return toResponse(inv);
    }

    @Transactional
    public InvitationResponse acceptInvitation(String code, Long tenantId) {
        Invitation inv = invitationRepository.findByInviteCode(code)
                .orElseThrow(() -> new IllegalArgumentException("Invalid invite code"));
        if (inv.getStatus() == InvitationStatus.ACCEPTED) {
            throw new IllegalArgumentException("Invitation already accepted");
        }
        if (inv.getExpiresAt().isBefore(LocalDateTime.now())) {
            inv.setStatus(InvitationStatus.EXPIRED);
            invitationRepository.save(inv);
            throw new IllegalArgumentException("Invitation expired");
        }

        User tenant = userRepository.findById(tenantId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        inv.setTenant(tenant);
        inv.setStatus(InvitationStatus.ACCEPTED);
        inv.setAcceptedAt(LocalDateTime.now());
        invitationRepository.save(inv);

        UnitSpace unit = inv.getUnitSpace();
        unit.setStatus("OCCUPIED");
        unitSpaceRepository.save(unit);

        notificationService.createNotification(inv.getLandlord().getId(),
                "Invitation Accepted",
                tenant.getFirstName() + " " + tenant.getLastName() + " accepted the invitation for " + unit.getName(),
                "INVITE", inv.getId(), "INVITATION");

        return toResponse(inv);
    }

    @Transactional
    public void cancelInvitation(Long invitationId, Long landlordId) {
        Invitation inv = invitationRepository.findById(invitationId)
                .orElseThrow(() -> new IllegalArgumentException("Invitation not found"));
        if (!inv.getLandlord().getId().equals(landlordId)) {
            throw new IllegalArgumentException("Access denied");
        }
        inv.setStatus(InvitationStatus.CANCELLED);
        invitationRepository.save(inv);
    }

    private InvitationResponse toResponse(Invitation inv) {
        return InvitationResponse.builder()
                .id(inv.getId())
                .unitSpaceId(inv.getUnitSpace().getId())
                .unitName(inv.getUnitSpace().getName())
                .propertyName(inv.getUnitSpace().getProperty().getName())
                .tenantEmail(inv.getTenantEmail())
                .tenantPhone(inv.getTenantPhone())
                .inviteCode(inv.getInviteCode())
                .status(inv.getStatus().name())
                .expiresAt(inv.getExpiresAt().toString())
                .tenantName(inv.getTenant() != null
                        ? inv.getTenant().getFirstName() + " " + inv.getTenant().getLastName()
                        : null)
                .build();
    }
}
