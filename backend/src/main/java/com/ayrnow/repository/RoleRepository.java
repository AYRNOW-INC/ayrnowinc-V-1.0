package com.ayrnow.repository;

import com.ayrnow.entity.Role;
import com.ayrnow.entity.RoleType;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface RoleRepository extends JpaRepository<Role, Long> {
    List<Role> findByUserId(Long userId);
    boolean existsByUserIdAndRole(Long userId, RoleType role);
}
