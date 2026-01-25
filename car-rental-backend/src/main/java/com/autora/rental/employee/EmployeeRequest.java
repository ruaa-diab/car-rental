package com.autora.rental.employee;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmployeeRequest {

    @NotBlank(message = "Full name is required")
    private String fullName;

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Phone is required")
    @Pattern(regexp = "^\\+97[02]\\d{9}$", message = "Phone must start with +970 or +972 followed by 9 digits")
    private String phone;

    @NotBlank(message = "Password is required")
    private String password;

    @NotBlank(message = "Position is required")
    private String position;

    private String department;

    private LocalDate hireDate;

    private String profileImageUrl;
}
