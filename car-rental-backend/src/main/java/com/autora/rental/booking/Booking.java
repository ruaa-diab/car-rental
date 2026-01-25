package com.autora.rental.booking;

import com.autora.rental.branch.Branch;
import com.autora.rental.car.Car;
import com.autora.rental.payment.Payment;
import com.autora.rental.user.User;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "bookings")
public class Booking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String bookingNumber;  // Auto-generated unique booking number

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnoreProperties({"bookings", "favorites", "password", "tokens"})
    private User user;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "car_id", nullable = false)
    @JsonIgnoreProperties({"bookings", "favorites", "availableBranches"})
    private Car car;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "pickup_branch_id", nullable = false)
    @JsonIgnoreProperties({"availableCars"})
    private Branch pickupBranch;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "return_branch_id", nullable = false)
    @JsonIgnoreProperties({"availableCars"})
    private Branch returnBranch;

    @Column(nullable = false)
    private LocalDate pickupDate;

    @Column(nullable = false)
    private LocalDate returnDate;

    private LocalTime pickupTime;

    private LocalTime returnTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private BookingStatus status;

    @Column(nullable = false)
    private BigDecimal pricePerDay;

    @Column(nullable = false)
    private Integer totalDays;

    @Column(nullable = false)
    private BigDecimal totalPrice;

    @OneToOne(mappedBy = "booking", cascade = CascadeType.ALL)
    @JsonIgnoreProperties({"booking"})
    private Payment payment;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    private LocalDateTime cancelledAt;

    private String cancellationReason;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (status == null) {
            status = BookingStatus.UPCOMING;
        }
        if (bookingNumber == null) {
            bookingNumber = generateBookingNumber();
        }
        calculateTotalDays();
        calculateTotalPrice();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    private String generateBookingNumber() {
        return "BK" + System.currentTimeMillis();
    }

    public void calculateTotalDays() {
        if (pickupDate != null && returnDate != null) {
            totalDays = (int) ChronoUnit.DAYS.between(pickupDate, returnDate);
            if (totalDays < 1) totalDays = 1;
        }
    }

    public void calculateTotalPrice() {
        if (pricePerDay != null && totalDays != null) {
            totalPrice = pricePerDay.multiply(BigDecimal.valueOf(totalDays));
        }
    }

    // Check if booking can be cancelled (e.g., only upcoming bookings)
    public boolean canCancel() {
        return status == BookingStatus.UPCOMING;
    }

    // Check if booking dates overlap with given dates
    public boolean overlapsWithDates(LocalDate startDate, LocalDate endDate) {
        return !(returnDate.isBefore(startDate) || pickupDate.isAfter(endDate));
    }
}
