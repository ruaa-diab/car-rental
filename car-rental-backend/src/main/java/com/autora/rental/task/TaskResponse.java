package com.autora.rental.task;

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
public class TaskResponse {

    private Long id;
    private TaskType type;
    private TaskStatus status;
    private TaskPriority priority;

    // Employee info
    private Long employeeId;
    private String employeeName;

    // Booking info
    private Long bookingId;
    private String bookingNumber;

    // Customer info
    private String customerName;
    private String customerPhone;
    private String customerEmail;

    // Car info
    private String carName;
    private String carPlate;
    private String carImageUrl;

    // Schedule
    private LocalDate scheduledDate;
    private LocalTime scheduledTime;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;

    // Location
    private String location;
    private String locationType;
    private Double latitude;
    private Double longitude;

    private String notes;
    private boolean isOverdue;
    private LocalDateTime createdAt;

    public static TaskResponse fromEntity(Task task) {
        TaskResponseBuilder builder = TaskResponse.builder()
                .id(task.getId())
                .type(task.getType())
                .status(task.getStatus())
                .priority(task.getPriority())
                .scheduledDate(task.getScheduledDate())
                .scheduledTime(task.getScheduledTime())
                .startedAt(task.getStartedAt())
                .completedAt(task.getCompletedAt())
                .location(task.getLocation())
                .locationType(task.getLocationType())
                .latitude(task.getLatitude())
                .longitude(task.getLongitude())
                .notes(task.getNotes())
                .isOverdue(task.isOverdue())
                .createdAt(task.getCreatedAt());

        // Employee info
        if (task.getEmployee() != null) {
            builder.employeeId(task.getEmployee().getId())
                    .employeeName(task.getEmployee().getFullName());
        }

        // Booking and customer info
        if (task.getBooking() != null) {
            builder.bookingId(task.getBooking().getId())
                    .bookingNumber(task.getBooking().getBookingNumber())
                    .customerName(task.getCustomerName())
                    .customerPhone(task.getCustomerPhone())
                    .customerEmail(task.getCustomerEmail());

            // Car info
            if (task.getBooking().getCar() != null) {
                builder.carName(task.getCarName())
                        .carPlate(task.getCarPlate())
                        .carImageUrl(task.getBooking().getCar().getImageUrl());
            }
        }

        return builder.build();
    }
}
