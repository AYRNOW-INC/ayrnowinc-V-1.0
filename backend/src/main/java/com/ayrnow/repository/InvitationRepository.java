package com.ayrnow.repository;

import com.ayrnow.entity.Invitation;
import com.ayrnow.entity.InvitationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface InvitationRepository extends JpaRepository<Invitation, Long> {
    Optional<Invitation> findByInviteCode(String inviteCode);
    List<Invitation> findByLandlordIdOrderByCreatedAtDesc(Long landlordId);
    List<Invitation> findByTenantEmailAndStatus(String email, InvitationStatus status);
    List<Invitation> findByUnitSpaceId(Long unitSpaceId);
}
