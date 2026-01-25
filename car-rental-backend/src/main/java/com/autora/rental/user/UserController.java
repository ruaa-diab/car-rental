package com.autora.rental.user;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;

    // Get current user profile
    @GetMapping("/profile")
    public ResponseEntity<UserProfileResponse> getCurrentUserProfile(@AuthenticationPrincipal User user) {
        UserProfileResponse response = UserProfileResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .profileImage(user.getProfileImage())
                .createdAt(user.getCreatedAt())
                .build();
        return ResponseEntity.ok(response);
    }

    // Update profile
    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(
            @AuthenticationPrincipal User user,
            @RequestBody UserUpdateRequest request
    ) {
        try {
            User updatedUser = userService.updateProfile(user.getId(), request);
            UserProfileResponse response = UserProfileResponse.builder()
                    .id(updatedUser.getId())
                    .fullName(updatedUser.getFullName())
                    .email(updatedUser.getEmail())
                    .phone(updatedUser.getPhone())
                    .profileImage(updatedUser.getProfileImage())
                    .createdAt(updatedUser.getCreatedAt())
                    .build();
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Change password
    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(
            @AuthenticationPrincipal User user,
            @RequestBody ChangePasswordRequest request
    ) {
        try {
            userService.changePassword(user.getId(), request.getCurrentPassword(), request.getNewPassword());
            return ResponseEntity.ok(Map.of("message", "Password changed successfully"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
