package com.ayrnow.repository;

import com.ayrnow.entity.UnitSpace;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface UnitSpaceRepository extends JpaRepository<UnitSpace, Long> {
    List<UnitSpace> findByPropertyIdOrderByName(Long propertyId);
    long countByPropertyId(Long propertyId);
    long countByPropertyIdAndStatus(Long propertyId, String status);
}
