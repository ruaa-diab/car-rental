package com.autora.rental.task;

import com.autora.rental.booking.Booking;
import com.autora.rental.employee.Employee;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "tasks")
public class Task {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaskType type;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private TaskStatus status = TaskStatus.PENDING;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private TaskPriority priority = TaskPriority.NORMAL;

    @ManyToOne
    @JoinColumn(name = "employee_id")
    private Employee employee;

    @ManyToOne
    @JoinColumn(name = "booking_id", nullable = false)
    private Booking booking;

    @Column(nullable = false)
    private LocalDate scheduledDate;

    private LocalTime scheduledTime;

    private LocalDateTime startedAt;

    private LocalDateTime completedAt;

    @Column(length = 1000)
    private String notes;

    // Location details
    @Column(length = 500)
    private String location;

    private String locationType; // home, branch

    private Double latitude;

    private Double longitude;

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
    public void startTask() {
        this.status = TaskStatus.IN_PROGRESS;
        this.startedAt = LocalDateTime.now();
    }

    public void completeTask() {
        this.status = TaskStatus.COMPLETED;
        this.completedAt = LocalDateTime.now();
    }

    public void cancelTask() {
        this.status = TaskStatus.CANCELLED;
    }

    public boolean isOverdue() {
        if (status == TaskStatus.COMPLETED || status == TaskStatus.CANCELLED) {
            return false;
        }
        LocalDateTime scheduledDateTime = LocalDateTime.of(scheduledDate,
                scheduledTime != null ? scheduledTime : LocalTime.of(23, 59));
        return LocalDateTime.now().isAfter(scheduledDateTime);
    }

    // Get customer info from booking
    public String getCustomerName() {
        return booking != null && booking.getUser() != null
                ? booking.getUser().getFullName()
                : null;
    }

    public String getCustomerPhone() {
        return booking != null && booking.getUser() != null
                ? booking.getUser().getPhone()
                : null;
    }

    public String getCustomerEmail() {
        return booking != null && booking.getUser() != null
                ? booking.getUser().getEmail()
                : null;
    }

    // Get car info from booking
    public String getCarName() {
        return booking != null && booking.getCar() != null
                ? booking.getCar().getBrand() + " " + booking.getCar().getModel()
                : null;
    }

    public String getCarPlate() {
        return booking != null && booking.getCar() != null
                ? booking.getCar().getLicensePlate()
                : null;
    }
}
