package com.ayrnow.service;

import com.ayrnow.dto.DashboardResponse;
import com.ayrnow.entity.*;
import com.ayrnow.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final PropertyRepository propertyRepository;
    private final UnitSpaceRepository unitSpaceRepository;
    private final LeaseRepository leaseRepository;
    private final InvitationRepository invitationRepository;
    private final PaymentRepository paymentRepository;
    private final MoveOutRequestRepository moveOutRepository;

    public DashboardResponse getLandlordDashboard(Long landlordId) {
        List<Property> properties = propertyRepository.findByLandlordIdOrderByCreatedAtDesc(landlordId);
        long totalUnits = 0, occupied = 0, vacant = 0;
        for (Property p : properties) {
            List<UnitSpace> units = unitSpaceRepository.findByPropertyIdOrderByName(p.getId());
            totalUnits += units.size();
            occupied += units.stream().filter(u -> "OCCUPIED".equals(u.getStatus())).count();
            vacant += units.stream().filter(u -> "VACANT".equals(u.getStatus())).count();
        }

        long activeLeases = leaseRepository.countByLandlordId(landlordId);
        List<Invitation> invitations = invitationRepository.findByLandlordIdOrderByCreatedAtDesc(landlordId);
        long pendingInvites = invitations.stream()
                .filter(i -> i.getStatus() == InvitationStatus.PENDING || i.getStatus() == InvitationStatus.SENT)
                .count();
        long pendingMoveOuts = moveOutRepository.findByLeaseLandlordIdOrderByCreatedAtDesc(landlordId).stream()
                .filter(m -> m.getStatus() == MoveOutStatus.SUBMITTED || m.getStatus() == MoveOutStatus.UNDER_REVIEW)
                .count();
        BigDecimal totalRevenue = paymentRepository.sumSuccessfulPaymentsByLandlordId(landlordId);

        return DashboardResponse.builder()
                .totalProperties((long) properties.size())
                .totalUnits(totalUnits)
                .occupiedUnits(occupied)
                .vacantUnits(vacant)
                .activeLeases(activeLeases)
                .pendingInvitations(pendingInvites)
                .pendingMoveOuts(pendingMoveOuts)
                .totalRevenue(totalRevenue)
                .build();
    }

    public DashboardResponse getTenantDashboard(Long tenantId) {
        List<Lease> leases = leaseRepository.findByTenantIdAndStatus(tenantId, LeaseStatus.FULLY_EXECUTED);
        Lease activeLease = leases.isEmpty() ? null : leases.get(0);

        var pending = paymentRepository.findByTenantIdAndStatus(tenantId, PaymentStatus.PENDING);
        BigDecimal amountDue = pending.stream()
                .map(Payment::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        String nextDueDate = pending.isEmpty() ? null : pending.get(0).getDueDate().toString();

        return DashboardResponse.builder()
                .activeLeases((long) leases.size())
                .amountDue(amountDue)
                .nextDueDate(nextDueDate)
                .leaseStatus(activeLease != null ? activeLease.getStatus().name() : "NONE")
                .propertyName(activeLease != null ? activeLease.getProperty().getName() : null)
                .unitName(activeLease != null ? activeLease.getUnitSpace().getName() : null)
                .build();
    }
}
