package com.autora.rental.employee;

import com.autora.rental.user.Role;
import com.autora.rental.user.User;
import com.autora.rental.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class EmployeeService {

    private final EmployeeRepository employeeRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public Page<EmployeeResponse> getAllEmployees(Pageable pageable) {
        return employeeRepository.findAll(pageable)
                .map(EmployeeResponse::fromEntity);
    }

    public Page<EmployeeResponse> getEmployeesByStatus(EmployeeStatus status, Pageable pageable) {
        return employeeRepository.findByStatus(status, pageable)
                .map(EmployeeResponse::fromEntity);
    }

    public Page<EmployeeResponse> searchEmployees(String search, EmployeeStatus status, Pageable pageable) {
        if (status != null) {
            return employeeRepository.searchEmployeesByStatus(search, status, pageable)
                    .map(EmployeeResponse::fromEntity);
        }
        return employeeRepository.searchEmployees(search, pageable)
                .map(EmployeeResponse::fromEntity);
    }

    public EmployeeResponse getEmployeeById(Long id) {
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + id));
        return EmployeeResponse.fromEntity(employee);
    }

    public EmployeeResponse getEmployeeByUserId(Long userId) {
        Employee employee = employeeRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Employee not found for user id: " + userId));
        return EmployeeResponse.fromEntity(employee);
    }

    public Employee getEmployeeEntityById(Long id) {
        return employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + id));
    }

    public Employee getEmployeeEntityByUserId(Long userId) {
        return employeeRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Employee not found for user id: " + userId));
    }

    @Transactional
    public EmployeeResponse createEmployee(EmployeeRequest request) {
        // Check if email already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered: " + request.getEmail());
        }

        // Check if phone already exists
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new RuntimeException("Phone already registered: " + request.getPhone());
        }

        // Create User with EMPLOYEE role
        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .phone(request.getPhone())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(Role.EMPLOYEE)
                .profileImageUrl(request.getProfileImageUrl())
                .hireDate(request.getHireDate() != null ? request.getHireDate() : LocalDate.now())
                .status("active")
                .position(request.getPosition())
                .department(request.getDepartment())
                .build();

        user = userRepository.save(user);

        // Create Employee record
        Employee employee = Employee.builder()
                .user(user)
                .position(request.getPosition())
                .department(request.getDepartment())
                .hireDate(request.getHireDate() != null ? request.getHireDate() : LocalDate.now())
                .status(EmployeeStatus.ACTIVE)
                .tasksCompleted(0)
                .rating(0.0)
                .totalRatings(0)
                .build();

        employee = employeeRepository.save(employee);
        return EmployeeResponse.fromEntity(employee);
    }

    @Transactional
    public EmployeeResponse updateEmployee(Long id, EmployeeUpdateRequest request) {
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + id));

        User user = employee.getUser();

        // Update User fields
        if (request.getFullName() != null) {
            user.setFullName(request.getFullName());
        }
        if (request.getPhone() != null) {
            // Check if phone is taken by another user
            if (!user.getPhone().equals(request.getPhone()) && userRepository.existsByPhone(request.getPhone())) {
                throw new RuntimeException("Phone already registered: " + request.getPhone());
            }
            user.setPhone(request.getPhone());
        }
        if (request.getProfileImageUrl() != null) {
            user.setProfileImageUrl(request.getProfileImageUrl());
        }

        // Update Employee fields
        if (request.getPosition() != null) {
            employee.setPosition(request.getPosition());
            user.setPosition(request.getPosition());
        }
        if (request.getDepartment() != null) {
            employee.setDepartment(request.getDepartment());
            user.setDepartment(request.getDepartment());
        }
        if (request.getHireDate() != null) {
            employee.setHireDate(request.getHireDate());
            user.setHireDate(request.getHireDate());
        }
        if (request.getStatus() != null) {
            employee.setStatus(request.getStatus());
            user.setStatus(request.getStatus().name().toLowerCase());
        }

        userRepository.save(user);
        employee = employeeRepository.save(employee);
        return EmployeeResponse.fromEntity(employee);
    }

    @Transactional
    public void deactivateEmployee(Long id) {
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + id));

        employee.setStatus(EmployeeStatus.INACTIVE);
        employee.getUser().setStatus("inactive");

        userRepository.save(employee.getUser());
        employeeRepository.save(employee);
    }

    @Transactional
    public void deleteEmployee(Long id) {
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + id));

        employeeRepository.delete(employee);
        // Note: User record is kept for audit purposes, just mark as inactive
        employee.getUser().setStatus("deleted");
        userRepository.save(employee.getUser());
    }

    public List<Employee> getActiveEmployees() {
        return employeeRepository.findByStatus(EmployeeStatus.ACTIVE);
    }

    public long countActiveEmployees() {
        return employeeRepository.countByStatus(EmployeeStatus.ACTIVE);
    }

    public long countAllEmployees() {
        return employeeRepository.count();
    }

    @Transactional
    public void incrementTasksCompleted(Long employeeId) {
        Employee employee = employeeRepository.findById(employeeId)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + employeeId));
        employee.incrementTasksCompleted();
        employeeRepository.save(employee);
    }

    @Transactional
    public void updateEmployeeRating(Long employeeId, double rating) {
        Employee employee = employeeRepository.findById(employeeId)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + employeeId));
        employee.updateRating(rating);
        employeeRepository.save(employee);
    }
}
