package com.ayrnow.service;

import com.ayrnow.dto.ProfileRequest;
import com.ayrnow.dto.UserResponse;
import com.ayrnow.entity.*;
import com.ayrnow.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final LandlordProfileRepository landlordProfileRepository;
    private final TenantProfileRepository tenantProfileRepository;

    public UserResponse getCurrentUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        return toResponse(user);
    }

    @Transactional
    public UserResponse updateProfile(Long userId, ProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (request.getFirstName() != null) user.setFirstName(request.getFirstName());
        if (request.getLastName() != null) user.setLastName(request.getLastName());
        if (request.getPhone() != null) user.setPhone(request.getPhone());
        userRepository.save(user);

        if (user.hasRole(RoleType.LANDLORD)) {
            landlordProfileRepository.findByUserId(userId).ifPresent(profile -> {
                if (request.getCompanyName() != null) profile.setCompanyName(request.getCompanyName());
                if (request.getBusinessAddress() != null) profile.setBusinessAddress(request.getBusinessAddress());
                if (request.getTaxId() != null) profile.setTaxId(request.getTaxId());
                landlordProfileRepository.save(profile);
            });
        }

        if (user.hasRole(RoleType.TENANT)) {
            tenantProfileRepository.findByUserId(userId).ifPresent(profile -> {
                if (request.getDateOfBirth() != null) profile.setDateOfBirth(request.getDateOfBirth());
                if (request.getSsnLastFour() != null) profile.setSsnLastFour(request.getSsnLastFour());
                if (request.getEmployer() != null) profile.setEmployer(request.getEmployer());
                if (request.getAnnualIncome() != null) profile.setAnnualIncome(request.getAnnualIncome());
                tenantProfileRepository.save(profile);
            });
        }

        return toResponse(user);
    }

    private UserResponse toResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .phone(user.getPhone())
                .status(user.getStatus().name())
                .roles(user.getRoles().stream().map(r -> r.getRole().name()).toList())
                .build();
    }
}
