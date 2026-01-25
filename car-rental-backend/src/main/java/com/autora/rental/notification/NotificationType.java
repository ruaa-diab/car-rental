package com.autora.rental.notification;

public enum NotificationType {
    BOOKING_CONFIRMED,    // When booking is successfully created
    BOOKING_CANCELLED,    // When booking is cancelled
    BOOKING_COMPLETED,    // When booking period ends
    BOOKING_REMINDER,     // Reminder before pickup date
    NEW_CAR,              // New car added to fleet
    SPECIAL_OFFER,        // Sales/promotional offers
    PAYMENT_SUCCESS,      // Payment completed
    PAYMENT_FAILED,       // Payment failed
    GENERAL               // General notifications
}
