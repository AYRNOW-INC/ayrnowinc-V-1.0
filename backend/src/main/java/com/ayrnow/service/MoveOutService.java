package com.ayrnow.service;

import com.ayrnow.dto.MoveOutRequestDto;
import com.ayrnow.dto.MoveOutResponse;
import com.ayrnow.dto.ReviewRequest;
import com.ayrnow.entity.*;
import com.ayrnow.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MoveOutService {

    private final MoveOutRequestRepository moveOutRepository;
    private final LeaseRepository leaseRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    @Transactional
    public MoveOutResponse createRequest(Long tenantId, MoveOutRequestDto request) {
        User tenant = userRepository.findById(tenantId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        Lease lease = leaseRepository.findById(request.getLeaseId())
                .orElseThrow(() -> new IllegalArgumentException("Lease not found"));
        if (!lease.getTenant().getId().equals(tenantId)) {
            throw new IllegalArgumentException("Access denied");
        }

        MoveOutRequest moveOut = MoveOutRequest.builder()
                .tenant(tenant)
                .lease(lease)
                .requestedDate(request.getRequestedDate())
                .reason(request.getReason())
                .build();
        moveOut = moveOutRepository.save(moveOut);

        notificationService.createNotification(lease.getLandlord().getId(),
                "Move-Out Request",
                tenant.getFirstName() + " " + tenant.getLastName() + " requested to move out of " +
                        lease.getUnitSpace().getName(),
                "MOVE_OUT", moveOut.getId(), "MOVE_OUT");

        return toResponse(moveOut);
    }

    public List<MoveOutResponse> getByTenant(Long tenantId) {
        return moveOutRepository.findByTenantIdOrderByCreatedAtDesc(tenantId).stream()
                .map(this::toResponse).toList();
    }

    public List<MoveOutResponse> getByLandlord(Long landlordId) {
        return moveOutRepository.findByLeaseLandlordIdOrderByCreatedAtDesc(landlordId).stream()
                .map(this::toResponse).toList();
    }

    @Transactional
    public MoveOutResponse reviewRequest(Long requestId, Long reviewerId, ReviewRequest review) {
        MoveOutRequest moveOut = moveOutRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Move-out request not found"));
        User reviewer = userRepository.findById(reviewerId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (!moveOut.getLease().getLandlord().getId().equals(reviewerId)) {
            throw new IllegalArgumentException("Access denied");
        }

        moveOut.setStatus(MoveOutStatus.valueOf(review.getStatus().toUpperCase()));
        moveOut.setReviewedBy(reviewer);
        moveOut.setReviewedAt(LocalDateTime.now());
        moveOut.setReviewComment(review.getComment());
        moveOutRepository.save(moveOut);

        notificationService.createNotification(moveOut.getTenant().getId(),
                "Move-Out " + review.getStatus(),
                "Your move-out request has been " + review.getStatus().toLowerCase(),
                "MOVE_OUT", moveOut.getId(), "MOVE_OUT");

        return toResponse(moveOut);
    }

    private MoveOutResponse toResponse(MoveOutRequest m) {
        return MoveOutResponse.builder()
                .id(m.getId())
                .tenantId(m.getTenant().getId())
                .tenantName(m.getTenant().getFirstName() + " " + m.getTenant().getLastName())
                .leaseId(m.getLease().getId())
                .propertyName(m.getLease().getProperty().getName())
                .unitName(m.getLease().getUnitSpace().getName())
                .requestedDate(m.getRequestedDate().toString())
                .reason(m.getReason())
                .status(m.getStatus().name())
                .reviewComment(m.getReviewComment())
                .reviewedAt(m.getReviewedAt() != null ? m.getReviewedAt().toString() : null)
                .createdAt(m.getCreatedAt().toString())
                .build();
    }
}
