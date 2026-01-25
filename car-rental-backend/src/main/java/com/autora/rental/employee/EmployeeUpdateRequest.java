package com.autora.rental.employee;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmployeeUpdateRequest {

    private String fullName;

    private String phone;

    private String position;

    private String department;

    private LocalDate hireDate;

    private EmployeeStatus status;

    private String profileImageUrl;
}
