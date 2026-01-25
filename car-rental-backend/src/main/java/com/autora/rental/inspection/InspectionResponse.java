package com.autora.rental.inspection;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InspectionResponse {

    private Long id;
    private Long taskId;
    private InspectionType type;

    // Task info
    private String taskType;
    private Long bookingId;
    private String bookingNumber;

    // Employee info
    private Long employeeId;
    private String employeeName;

    // Car info
    private String carName;
    private String carPlate;

    // Customer info
    private String customerName;

    // Inspection details
    private Integer odometerReading;
    private String fuelLevel;
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
    private LocalDateTime createdAt;

    public static InspectionResponse fromEntity(Inspection inspection) {
        InspectionResponseBuilder builder = InspectionResponse.builder()
                .id(inspection.getId())
                .taskId(inspection.getTask() != null ? inspection.getTask().getId() : null)
                .type(inspection.getType())
                .odometerReading(inspection.getOdometerReading())
                .fuelLevel(inspection.getFuelLevel())
                .exteriorCondition(inspection.getExteriorCondition())
                .interiorCondition(inspection.getInteriorCondition())
                .featuresCheck(inspection.getFeaturesCheck())
                .documentsVerified(inspection.getDocumentsVerified())
                .customerIdVerified(inspection.getCustomerIdVerified())
                .licenseVerified(inspection.getLicenseVerified())
                .customerSignature(inspection.getCustomerSignature())
                .photos(inspection.getPhotos())
                .notes(inspection.getNotes())
                .damageNotes(inspection.getDamageNotes())
                .createdAt(inspection.getCreatedAt());

        // Task info
        if (inspection.getTask() != null) {
            builder.taskType(inspection.getTask().getType().name());

            if (inspection.getTask().getBooking() != null) {
                builder.bookingId(inspection.getTask().getBooking().getId())
                        .bookingNumber(inspection.getTask().getBooking().getBookingNumber());

                if (inspection.getTask().getBooking().getUser() != null) {
                    builder.customerName(inspection.getTask().getBooking().getUser().getFullName());
                }

                if (inspection.getTask().getBooking().getCar() != null) {
                    builder.carName(inspection.getTask().getCarName())
                            .carPlate(inspection.getTask().getCarPlate());
                }
            }

            if (inspection.getTask().getEmployee() != null) {
                builder.employeeId(inspection.getTask().getEmployee().getId())
                        .employeeName(inspection.getTask().getEmployee().getFullName());
            }
        }

        return builder.build();
    }
}
