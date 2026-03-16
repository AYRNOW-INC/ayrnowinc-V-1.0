package com.ayrnow.service;

import com.ayrnow.dto.*;
import com.ayrnow.entity.*;
import com.ayrnow.repository.*;
import com.ayrnow.security.JwtProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final LandlordProfileRepository landlordProfileRepository;
    private final TenantProfileRepository tenantProfileRepository;
    private final InvitationRepository invitationRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtProvider jwtProvider;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already registered");
        }

        final User user = userRepository.save(User.builder()
                .email(request.getEmail())
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .phone(request.getPhone())
                .externalId(passwordEncoder.encode(request.getPassword()))
                .build());

        RoleType roleType = RoleType.valueOf(request.getRole().toUpperCase());
        Role role = Role.builder().user(user).role(roleType).build();
        roleRepository.save(role);

        if (roleType == RoleType.LANDLORD) {
            landlordProfileRepository.save(LandlordProfile.builder().user(user).build());
        } else {
            tenantProfileRepository.save(TenantProfile.builder().user(user).build());
        }

        // If registering with invite code, accept the invitation
        if (request.getInviteCode() != null && !request.getInviteCode().isBlank()) {
            invitationRepository.findByInviteCode(request.getInviteCode()).ifPresent(inv -> {
                if (inv.getStatus() == InvitationStatus.PENDING || inv.getStatus() == InvitationStatus.SENT) {
                    inv.setTenant(user);
                    inv.setStatus(InvitationStatus.ACCEPTED);
                    inv.setAcceptedAt(java.time.LocalDateTime.now());
                    invitationRepository.save(inv);

                    UnitSpace unit = inv.getUnitSpace();
                    unit.setStatus("OCCUPIED");
                }
            });
        }

        List<String> roles = List.of(roleType.name());
        String accessToken = jwtProvider.generateAccessToken(user.getId(), user.getEmail(), roles);
        String refreshToken = jwtProvider.generateRefreshToken(user.getId());

        return AuthResponse.builder()
                .userId(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .roles(roles)
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    public AuthResponse login(AuthRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Invalid credentials"));

        if (!passwordEncoder.matches(request.getPassword(), user.getExternalId())) {
            throw new IllegalArgumentException("Invalid credentials");
        }

        List<String> roles = user.getRoles().stream()
                .map(r -> r.getRole().name())
                .toList();

        String accessToken = jwtProvider.generateAccessToken(user.getId(), user.getEmail(), roles);
        String refreshToken = jwtProvider.generateRefreshToken(user.getId());

        return AuthResponse.builder()
                .userId(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .roles(roles)
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    public AuthResponse refreshToken(String refreshToken) {
        if (!jwtProvider.validateToken(refreshToken)) {
            throw new IllegalArgumentException("Invalid refresh token");
        }
        Long userId = jwtProvider.getUserId(refreshToken);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        List<String> roles = user.getRoles().stream()
                .map(r -> r.getRole().name())
                .toList();

        String newAccessToken = jwtProvider.generateAccessToken(user.getId(), user.getEmail(), roles);
        String newRefreshToken = jwtProvider.generateRefreshToken(user.getId());

        return AuthResponse.builder()
                .userId(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .roles(roles)
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .build();
    }
}
