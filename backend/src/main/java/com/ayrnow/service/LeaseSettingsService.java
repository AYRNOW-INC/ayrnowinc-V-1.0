package com.ayrnow.service;

import com.ayrnow.dto.LeaseSettingsRequest;
import com.ayrnow.dto.LeaseSettingsResponse;
import com.ayrnow.entity.LeaseSettings;
import com.ayrnow.entity.Property;
import com.ayrnow.repository.LeaseSettingsRepository;
import com.ayrnow.repository.PropertyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LeaseSettingsService {

    private final LeaseSettingsRepository leaseSettingsRepository;
    private final PropertyRepository propertyRepository;

    public LeaseSettingsResponse getByProperty(Long propertyId, Long userId) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        if (!property.getLandlord().getId().equals(userId)) {
            throw new IllegalArgumentException("Access denied");
        }
        LeaseSettings ls = leaseSettingsRepository.findByPropertyId(propertyId)
                .orElseGet(() -> {
                    LeaseSettings newLs = LeaseSettings.builder().property(property).build();
                    return leaseSettingsRepository.save(newLs);
                });
        return toResponse(ls);
    }

    @Transactional
    public LeaseSettingsResponse update(Long propertyId, Long userId, LeaseSettingsRequest request) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        if (!property.getLandlord().getId().equals(userId)) {
            throw new IllegalArgumentException("Access denied");
        }
        LeaseSettings ls = leaseSettingsRepository.findByPropertyId(propertyId)
                .orElseGet(() -> LeaseSettings.builder().property(property).build());

        if (request.getDefaultLeaseTermMonths() != null) ls.setDefaultLeaseTermMonths(request.getDefaultLeaseTermMonths());
        if (request.getDefaultMonthlyRent() != null) ls.setDefaultMonthlyRent(request.getDefaultMonthlyRent());
        if (request.getDefaultSecurityDeposit() != null) ls.setDefaultSecurityDeposit(request.getDefaultSecurityDeposit());
        if (request.getPaymentDueDay() != null) ls.setPaymentDueDay(request.getPaymentDueDay());
        if (request.getGracePeriodDays() != null) ls.setGracePeriodDays(request.getGracePeriodDays());
        if (request.getLateFeeAmount() != null) ls.setLateFeeAmount(request.getLateFeeAmount());
        if (request.getLateFeeType() != null) ls.setLateFeeType(request.getLateFeeType());
        if (request.getSpecialTerms() != null) ls.setSpecialTerms(request.getSpecialTerms());

        leaseSettingsRepository.save(ls);
        return toResponse(ls);
    }

    private LeaseSettingsResponse toResponse(LeaseSettings ls) {
        return LeaseSettingsResponse.builder()
                .id(ls.getId())
                .propertyId(ls.getProperty().getId())
                .defaultLeaseTermMonths(ls.getDefaultLeaseTermMonths())
                .defaultMonthlyRent(ls.getDefaultMonthlyRent())
                .defaultSecurityDeposit(ls.getDefaultSecurityDeposit())
                .paymentDueDay(ls.getPaymentDueDay())
                .gracePeriodDays(ls.getGracePeriodDays())
                .lateFeeAmount(ls.getLateFeeAmount())
                .lateFeeType(ls.getLateFeeType())
                .specialTerms(ls.getSpecialTerms())
                .build();
    }
}
