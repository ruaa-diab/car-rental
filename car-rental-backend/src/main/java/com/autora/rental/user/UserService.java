package com.autora.rental.user;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // Get user by ID
    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    // Get user by email
    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    // Update user profile
    @Transactional
    public User updateProfile(Long userId, UserUpdateRequest request) {
        User user = getUserById(userId);

        if (request.getFullName() != null) {
            user.setFullName(request.getFullName());
        }
        if (request.getPhone() != null) {
            // Check if phone is already taken by another user
            if (!user.getPhone().equals(request.getPhone()) && 
                userRepository.existsByPhone(request.getPhone())) {
                throw new RuntimeException("Phone number already in use");
            }
            user.setPhone(request.getPhone());
        }
        if (request.getProfileImage() != null) {
            user.setProfileImageUrl(request.getProfileImage());
        }

        return userRepository.save(user);
    }

    // Change password
    @Transactional
    public void changePassword(Long userId, String currentPassword, String newPassword) {
        User user = getUserById(userId);

        // Verify current password
        if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
            throw new RuntimeException("Current password is incorrect");
        }

        // Update password
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }
}
