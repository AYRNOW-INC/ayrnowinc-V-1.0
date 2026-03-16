package com.ayrnow.repository;

import com.ayrnow.entity.Lease;
import com.ayrnow.entity.LeaseStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface LeaseRepository extends JpaRepository<Lease, Long> {
    List<Lease> findByLandlordIdOrderByCreatedAtDesc(Long landlordId);
    List<Lease> findByTenantIdOrderByCreatedAtDesc(Long tenantId);
    List<Lease> findByPropertyId(Long propertyId);
    List<Lease> findByUnitSpaceId(Long unitSpaceId);
    List<Lease> findByTenantIdAndStatus(Long tenantId, LeaseStatus status);
    long countByLandlordId(Long landlordId);
    long countByTenantId(Long tenantId);
}
