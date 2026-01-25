package com.autora.rental.employee;

import com.autora.rental.user.User;
import jakarta.persistence.*;
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
@Entity
@Table(name = "employees")
public class Employee {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    private String position;

    private String department;

    private LocalDate hireDate;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private EmployeeStatus status = EmployeeStatus.ACTIVE;

    @Builder.Default
    private Integer tasksCompleted = 0;

    @Builder.Default
    private Double rating = 0.0;

    @Builder.Default
    private Integer totalRatings = 0;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Helper methods
    public String getFullName() {
        return user != null ? user.getFullName() : null;
    }

    public String getEmail() {
        return user != null ? user.getEmail() : null;
    }

    public String getPhone() {
        return user != null ? user.getPhone() : null;
    }

    public String getProfileImage() {
        return user != null ? user.getProfileImageUrl() : null;
    }

    public void incrementTasksCompleted() {
        this.tasksCompleted++;
    }

    public void updateRating(double newRating) {
        double totalScore = this.rating * this.totalRatings + newRating;
        this.totalRatings++;
        this.rating = totalScore / this.totalRatings;
    }
}
