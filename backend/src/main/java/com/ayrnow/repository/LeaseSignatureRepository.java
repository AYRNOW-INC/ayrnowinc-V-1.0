package com.ayrnow.repository;

import com.ayrnow.entity.LeaseSignature;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface LeaseSignatureRepository extends JpaRepository<LeaseSignature, Long> {
    List<LeaseSignature> findByLeaseId(Long leaseId);
    Optional<LeaseSignature> findByLeaseIdAndSignerId(Long leaseId, Long signerId);
}
