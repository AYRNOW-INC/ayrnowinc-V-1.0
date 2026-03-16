package com.ayrnow.service;

import com.ayrnow.entity.AuditLog;
import com.ayrnow.entity.User;
import com.ayrnow.repository.AuditLogRepository;
import com.ayrnow.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuditService {

    private final AuditLogRepository auditLogRepository;
    private final UserRepository userRepository;

    public void log(Long userId, String action, String entityType, Long entityId, String details) {
        User user = userId != null ? userRepository.findById(userId).orElse(null) : null;
        auditLogRepository.save(AuditLog.builder()
                .user(user)
                .action(action)
                .entityType(entityType)
                .entityId(entityId)
                .details(details)
                .build());
    }
}
