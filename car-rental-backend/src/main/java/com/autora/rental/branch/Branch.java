package com.autora.rental.branch;

import com.autora.rental.car.Car;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "branches")
public class Branch {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String address;

    private String city;

    private String country;

    // GPS Coordinates for Map
    private Double latitude;

    private Double longitude;

    private String phone;

    private String email;

    // Operating hours
    private String openingTime;  // e.g., "08:00"
    private String closingTime;  // e.g., "20:00"

    private boolean isActive;

    @JsonIgnore
    @ManyToMany(mappedBy = "availableBranches")
    private List<Car> availableCars;

    @PrePersist
    protected void onCreate() {
        isActive = true;
    }
}
