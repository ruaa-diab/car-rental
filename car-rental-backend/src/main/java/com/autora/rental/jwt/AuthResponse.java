package com.autora.rental.jwt;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String token;
    private String email;
    private String fullName;
    private String phone;
    private Long userId;
    private String role;
    private Long employeeId;  // Only set for EMPLOYEE/MANAGER roles
    private String message;
}
