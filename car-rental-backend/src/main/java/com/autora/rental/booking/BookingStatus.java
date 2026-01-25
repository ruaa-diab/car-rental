package com.autora.rental.booking;

public enum BookingStatus {
    UPCOMING,    // Booking is confirmed, waiting for pickup date
    ACTIVE,      // Customer has picked up the car
    COMPLETED,   // Car has been returned
    CANCELLED    // Booking was cancelled
}
