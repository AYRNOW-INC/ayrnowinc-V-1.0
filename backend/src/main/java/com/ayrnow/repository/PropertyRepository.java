package com.ayrnow.repository;

import com.ayrnow.entity.Property;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PropertyRepository extends JpaRepository<Property, Long> {
    List<Property> findByLandlordIdOrderByCreatedAtDesc(Long landlordId);
    long countByLandlordId(Long landlordId);
}
