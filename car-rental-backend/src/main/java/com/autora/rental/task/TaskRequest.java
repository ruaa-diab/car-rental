package com.autora.rental.task;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaskRequest {

    @NotNull(message = "Task type is required")
    private TaskType type;

    private TaskPriority priority;

    private Long employeeId;

    @NotNull(message = "Booking ID is required")
    private Long bookingId;

    @NotNull(message = "Scheduled date is required")
    private LocalDate scheduledDate;

    private LocalTime scheduledTime;

    private String notes;

    private String location;

    private String locationType;

    private Double latitude;

    private Double longitude;
}
