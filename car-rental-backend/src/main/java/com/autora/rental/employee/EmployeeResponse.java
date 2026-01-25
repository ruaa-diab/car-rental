package com.autora.rental.employee;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmployeeResponse {

    private Long id;
    private Long userId;
    private String fullName;
    private String email;
    private String phone;
    private String position;
    private String department;
    private LocalDate hireDate;
    private EmployeeStatus status;
    private Integer tasksCompleted;
    private Double rating;
    private String profileImageUrl;
    private LocalDateTime createdAt;

    public static EmployeeResponse fromEntity(Employee employee) {
        return EmployeeResponse.builder()
                .id(employee.getId())
                .userId(employee.getUser() != null ? employee.getUser().getId() : null)
                .fullName(employee.getFullName())
                .email(employee.getEmail())
                .phone(employee.getPhone())
                .position(employee.getPosition())
                .department(employee.getDepartment())
                .hireDate(employee.getHireDate())
                .status(employee.getStatus())
                .tasksCompleted(employee.getTasksCompleted())
                .rating(employee.getRating())
                .profileImageUrl(employee.getProfileImage())
                .createdAt(employee.getCreatedAt())
                .build();
    }
}
