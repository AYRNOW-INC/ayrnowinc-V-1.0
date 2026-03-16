package com.ayrnow.repository;

import com.ayrnow.entity.TenantProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface TenantProfileRepository extends JpaRepository<TenantProfile, Long> {
    Optional<TenantProfile> findByUserId(Long userId);
}
