package com.ayrnow.repository;

import com.ayrnow.entity.MoveOutRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MoveOutRequestRepository extends JpaRepository<MoveOutRequest, Long> {
    List<MoveOutRequest> findByTenantIdOrderByCreatedAtDesc(Long tenantId);
    List<MoveOutRequest> findByLeaseIdOrderByCreatedAtDesc(Long leaseId);
    List<MoveOutRequest> findByLeaseLandlordIdOrderByCreatedAtDesc(Long landlordId);
}
