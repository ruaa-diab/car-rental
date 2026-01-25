package com.autora.rental.inspection;

import com.autora.rental.task.Task;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "inspections")
public class Inspection {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "task_id", nullable = false)
    private Task task;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private InspectionType type;

    private Integer odometerReading;

    private String fuelLevel; // e.g., "50%", "Full", "Empty"

    // Exterior condition - stored as JSON string
    @Column(length = 2000)
    private String exteriorCondition;

    // Interior condition - stored as JSON string
    @Column(length = 2000)
    private String interiorCondition;

    // Features check - stored as JSON string
    @Column(length = 2000)
    private String featuresCheck;

    private Boolean documentsVerified;

    private Boolean customerIdVerified;

    private Boolean licenseVerified;

    // Signature image URL
    private String customerSignature;

    // Photos stored as comma-separated URLs or in a separate table
    @ElementCollection
    @CollectionTable(name = "inspection_photos", joinColumns = @JoinColumn(name = "inspection_id"))
    @Column(name = "photo_url")
    @Builder.Default
    private List<String> photos = new ArrayList<>();

    @Column(length = 1000)
    private String notes;

    @Column(length = 1000)
    private String damageNotes;

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
    public void addPhoto(String photoUrl) {
        if (photos == null) {
            photos = new ArrayList<>();
        }
        photos.add(photoUrl);
    }

    public void removePhoto(String photoUrl) {
        if (photos != null) {
            photos.remove(photoUrl);
        }
    }
}
