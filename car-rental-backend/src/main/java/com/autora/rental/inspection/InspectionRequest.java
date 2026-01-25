package com.autora.rental.inspection;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InspectionRequest {

    @NotNull(message = "Task ID is required")
    private Long taskId;

    @NotNull(message = "Inspection type is required")
    private InspectionType type;

    private Integer odometerReading;

    private String fuelLevel;

    // JSON strings for condition details
    private String exteriorCondition;

    private String interiorCondition;

    private String featuresCheck;

    private Boolean documentsVerified;

    private Boolean customerIdVerified;

    private Boolean licenseVerified;

    private String customerSignature;

    private List<String> photos;

    private String notes;

    private String damageNotes;
}
