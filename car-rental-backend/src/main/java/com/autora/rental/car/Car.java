package com.autora.rental.car;

import com.autora.rental.booking.Booking;
import com.autora.rental.branch.Branch;
import com.autora.rental.favorite.Favorite;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "cars")
public class Car {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;  // e.g., "Tesla Model 3"

    @Column(nullable = false)
    private String brand;  // e.g., "Tesla"

    @Column(nullable = false)
    private String model;  // e.g., "Model 3"

    private Integer year;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CarType type;  // SEDAN, SUV, SPORT, ELECTRIC, LUXURY

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TransmissionType transmission;  // AUTOMATIC, MANUAL

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private FuelType fuel;  // PETROL, DIESEL, ELECTRIC, HYBRID

    @Column(nullable = false)
    private BigDecimal pricePerDay;

    private Integer seats;

    private String color;

    private String licensePlate;

    // Car images - stored as URLs (comma-separated or use @ElementCollection)
    @Column(length = 2000)
    private String imageUrl;

    @ElementCollection
    @CollectionTable(name = "car_images", joinColumns = @JoinColumn(name = "car_id"))
    @Column(name = "image_url")
    private List<String> additionalImages;

    private Double rating;

    private Integer reviewCount;

    // Quantity management
    @Column(nullable = false)
    private Integer totalQuantity;

    @Column(nullable = false)
    private Integer availableQuantity;

    private String description;

    // Features (comma-separated or use @ElementCollection)
    @ElementCollection
    @CollectionTable(name = "car_features", joinColumns = @JoinColumn(name = "car_id"))
    @Column(name = "feature")
    private List<String> features;

    @Column(nullable = false)
    private boolean isActive;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    // Many-to-Many with branches
    @ManyToMany
    @JoinTable(
        name = "car_branch",
        joinColumns = @JoinColumn(name = "car_id"),
        inverseJoinColumns = @JoinColumn(name = "branch_id")
    )
    private List<Branch> availableBranches;

    @JsonIgnore
    @OneToMany(mappedBy = "car", cascade = CascadeType.ALL)
    private List<Booking> bookings;

    @JsonIgnore
    @OneToMany(mappedBy = "car", cascade = CascadeType.ALL)
    private List<Favorite> favorites;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        isActive = true;
        if (availableQuantity == null) {
            availableQuantity = totalQuantity;
        }
        if (rating == null) {
            rating = 0.0;
        }
        if (reviewCount == null) {
            reviewCount = 0;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Helper method to check availability
    public boolean isAvailable() {
        return isActive && availableQuantity > 0;
    }

    // Decrement available quantity when booking
    public boolean decrementQuantity() {
        if (availableQuantity > 0) {
            availableQuantity--;
            return true;
        }
        return false;
    }

    // Increment available quantity when booking is completed/cancelled
    public void incrementQuantity() {
        if (availableQuantity < totalQuantity) {
            availableQuantity++;
        }
    }
}
