package com.ayrnow.repository;

import com.ayrnow.entity.TenantDocument;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TenantDocumentRepository extends JpaRepository<TenantDocument, Long> {
    List<TenantDocument> findByTenantIdOrderByCreatedAtDesc(Long tenantId);
    List<TenantDocument> findByLeaseId(Long leaseId);
    List<TenantDocument> findByTenantIdAndLeaseId(Long tenantId, Long leaseId);
}
