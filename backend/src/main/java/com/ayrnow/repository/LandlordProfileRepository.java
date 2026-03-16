package com.ayrnow.repository;

import com.ayrnow.entity.LandlordProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface LandlordProfileRepository extends JpaRepository<LandlordProfile, Long> {
    Optional<LandlordProfile> findByUserId(Long userId);
}
