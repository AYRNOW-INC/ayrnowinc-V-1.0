package com.ayrnow.repository;

import com.ayrnow.entity.LeaseSettings;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface LeaseSettingsRepository extends JpaRepository<LeaseSettings, Long> {
    Optional<LeaseSettings> findByPropertyId(Long propertyId);
}
