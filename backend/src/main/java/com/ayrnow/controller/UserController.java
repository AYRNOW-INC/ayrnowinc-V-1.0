package com.ayrnow.controller;

import com.ayrnow.dto.ProfileRequest;
import com.ayrnow.dto.UserResponse;
import com.ayrnow.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<UserResponse> getCurrentUser(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(userService.getCurrentUser(userId));
    }

    @PutMapping("/me")
    public ResponseEntity<UserResponse> updateProfile(Authentication auth,
                                                       @RequestBody ProfileRequest request) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(userService.updateProfile(userId, request));
    }
}
