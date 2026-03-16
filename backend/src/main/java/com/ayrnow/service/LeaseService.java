package com.ayrnow.service;

import com.ayrnow.dto.*;
import com.ayrnow.entity.*;
import com.ayrnow.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class LeaseService {

    private final LeaseRepository leaseRepository;
    private final LeaseSignatureRepository leaseSignatureRepository;
    private final PropertyRepository propertyRepository;
    private final UnitSpaceRepository unitSpaceRepository;
    private final PaymentService paymentService;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    @Transactional
    public LeaseResponse createLease(Long landlordId, LeaseRequest request) {
        User landlord = userRepository.findById(landlordId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        Property property = propertyRepository.findById(request.getPropertyId())
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        if (!property.getLandlord().getId().equals(landlordId)) {
            throw new IllegalArgumentException("Access denied");
        }
        UnitSpace unit = unitSpaceRepository.findById(request.getUnitSpaceId())
                .orElseThrow(() -> new IllegalArgumentException("Unit not found"));
        User tenant = userRepository.findById(request.getTenantId())
                .orElseThrow(() -> new IllegalArgumentException("Tenant not found"));

        java.time.LocalDate endDate = request.getStartDate().plusMonths(request.getLeaseTermMonths());

        Lease lease = Lease.builder()
                .property(property)
                .unitSpace(unit)
                .landlord(landlord)
                .tenant(tenant)
                .leaseTermMonths(request.getLeaseTermMonths())
                .monthlyRent(request.getMonthlyRent())
                .securityDeposit(request.getSecurityDeposit())
                .startDate(request.getStartDate())
                .endDate(endDate)
                .paymentDueDay(request.getPaymentDueDay() != null ? request.getPaymentDueDay() : 1)
                .gracePeriodDays(request.getGracePeriodDays() != null ? request.getGracePeriodDays() : 5)
                .lateFeeAmount(request.getLateFeeAmount())
                .lateFeeType(request.getLateFeeType())
                .specialTerms(request.getSpecialTerms())
                .build();
        lease = leaseRepository.save(lease);

        // Create signature records for both parties
        leaseSignatureRepository.save(LeaseSignature.builder()
                .lease(lease).signer(landlord).signerRole("LANDLORD").build());
        leaseSignatureRepository.save(LeaseSignature.builder()
                .lease(lease).signer(tenant).signerRole("TENANT").build());

        notificationService.createNotification(tenant.getId(),
                "New Lease Created",
                "A new lease has been created for " + unit.getName() + " at " + property.getName(),
                "LEASE", lease.getId(), "LEASE");

        return toResponse(lease);
    }

    public List<LeaseResponse> getLeasesByLandlord(Long landlordId) {
        return leaseRepository.findByLandlordIdOrderByCreatedAtDesc(landlordId).stream()
                .map(this::toResponse).toList();
    }

    public List<LeaseResponse> getLeasesByTenant(Long tenantId) {
        return leaseRepository.findByTenantIdOrderByCreatedAtDesc(tenantId).stream()
                .map(this::toResponse).toList();
    }

    public LeaseResponse getLease(Long leaseId, Long userId) {
        Lease lease = leaseRepository.findById(leaseId)
                .orElseThrow(() -> new IllegalArgumentException("Lease not found"));
        if (!lease.getLandlord().getId().equals(userId) && !lease.getTenant().getId().equals(userId)) {
            throw new IllegalArgumentException("Access denied");
        }
        return toResponse(lease);
    }

    @Transactional
    public LeaseResponse sendForSigning(Long leaseId, Long landlordId) {
        Lease lease = leaseRepository.findById(leaseId)
                .orElseThrow(() -> new IllegalArgumentException("Lease not found"));
        if (!lease.getLandlord().getId().equals(landlordId)) {
            throw new IllegalArgumentException("Access denied");
        }
        if (lease.getStatus() != LeaseStatus.DRAFT) {
            throw new IllegalArgumentException("Lease must be in DRAFT status");
        }
        lease.setStatus(LeaseStatus.SENT_FOR_SIGNING);
        leaseRepository.save(lease);

        notificationService.createNotification(lease.getTenant().getId(),
                "Lease Ready for Signing",
                "Your lease for " + lease.getUnitSpace().getName() + " is ready to sign",
                "LEASE", lease.getId(), "LEASE");

        return toResponse(lease);
    }

    @Transactional
    public LeaseResponse signLease(Long leaseId, Long signerId, String ipAddress) {
        Lease lease = leaseRepository.findById(leaseId)
                .orElseThrow(() -> new IllegalArgumentException("Lease not found"));
        if (!lease.getLandlord().getId().equals(signerId) && !lease.getTenant().getId().equals(signerId)) {
            throw new IllegalArgumentException("Access denied");
        }

        LeaseSignature sig = leaseSignatureRepository.findByLeaseIdAndSignerId(leaseId, signerId)
                .orElseThrow(() -> new IllegalArgumentException("Signature record not found"));

        sig.setSigned(true);
        sig.setSignedAt(LocalDateTime.now());
        sig.setIpAddress(ipAddress);
        leaseSignatureRepository.save(sig);

        // Update lease status based on signatures
        List<LeaseSignature> allSigs = leaseSignatureRepository.findByLeaseId(leaseId);
        boolean allSigned = allSigs.stream().allMatch(LeaseSignature::getSigned);
        boolean landlordSigned = allSigs.stream()
                .anyMatch(s -> "LANDLORD".equals(s.getSignerRole()) && s.getSigned());
        boolean tenantSigned = allSigs.stream()
                .anyMatch(s -> "TENANT".equals(s.getSignerRole()) && s.getSigned());

        if (allSigned) {
            lease.setStatus(LeaseStatus.FULLY_EXECUTED);
            // Auto-create first rent payment when lease is fully executed
            paymentService.createPaymentForLease(lease.getId());
        } else if (landlordSigned) {
            lease.setStatus(LeaseStatus.LANDLORD_SIGNED);
        } else if (tenantSigned) {
            lease.setStatus(LeaseStatus.TENANT_SIGNED);
        }
        leaseRepository.save(lease);

        // Notify the other party
        Long notifyId = signerId.equals(lease.getLandlord().getId())
                ? lease.getTenant().getId() : lease.getLandlord().getId();
        String signerName = signerId.equals(lease.getLandlord().getId())
                ? "Landlord" : "Tenant";
        notificationService.createNotification(notifyId,
                "Lease Signed",
                signerName + " has signed the lease for " + lease.getUnitSpace().getName(),
                "LEASE", lease.getId(), "LEASE");

        return toResponse(lease);
    }

    private LeaseResponse toResponse(Lease l) {
        List<LeaseSignature> sigs = leaseSignatureRepository.findByLeaseId(l.getId());
        return LeaseResponse.builder()
                .id(l.getId())
                .propertyId(l.getProperty().getId())
                .propertyName(l.getProperty().getName())
                .unitSpaceId(l.getUnitSpace().getId())
                .unitName(l.getUnitSpace().getName())
                .landlordId(l.getLandlord().getId())
                .landlordName(l.getLandlord().getFirstName() + " " + l.getLandlord().getLastName())
                .tenantId(l.getTenant().getId())
                .tenantName(l.getTenant().getFirstName() + " " + l.getTenant().getLastName())
                .leaseTermMonths(l.getLeaseTermMonths())
                .monthlyRent(l.getMonthlyRent())
                .securityDeposit(l.getSecurityDeposit())
                .startDate(l.getStartDate().toString())
                .endDate(l.getEndDate().toString())
                .paymentDueDay(l.getPaymentDueDay())
                .gracePeriodDays(l.getGracePeriodDays())
                .lateFeeAmount(l.getLateFeeAmount())
                .lateFeeType(l.getLateFeeType())
                .specialTerms(l.getSpecialTerms())
                .status(l.getStatus().name())
                .documentUrl(l.getDocumentUrl())
                .signatures(sigs.stream().map(s -> SignatureResponse.builder()
                        .id(s.getId())
                        .signerId(s.getSigner().getId())
                        .signerName(s.getSigner().getFirstName() + " " + s.getSigner().getLastName())
                        .signerRole(s.getSignerRole())
                        .signed(s.getSigned())
                        .signedAt(s.getSignedAt() != null ? s.getSignedAt().toString() : null)
                        .build()).toList())
                .build();
    }
}
