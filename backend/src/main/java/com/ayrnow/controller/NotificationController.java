package com.ayrnow.controller;

import com.ayrnow.dto.NotificationResponse;
import com.ayrnow.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<List<NotificationResponse>> getAll(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(notificationService.getNotifications(userId));
    }

    @GetMapping("/unread")
    public ResponseEntity<List<NotificationResponse>> getUnread(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(notificationService.getUnreadNotifications(userId));
    }

    @GetMapping("/unread/count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(Map.of("count", notificationService.getUnreadCount(userId)));
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markRead(Authentication auth, @PathVariable Long id) {
        Long userId = (Long) auth.getPrincipal();
        notificationService.markAsRead(id, userId);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/read-all")
    public ResponseEntity<Void> markAllRead(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        notificationService.markAllAsRead(userId);
        return ResponseEntity.ok().build();
    }
}
