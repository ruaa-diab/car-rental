package com.autora.rental.booking;

import com.autora.rental.user.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/bookings")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class BookingController {

    private final BookingService bookingService;

    // Get all user bookings
    @GetMapping
    public ResponseEntity<List<Booking>> getUserBookings(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(bookingService.getUserBookings(user.getId()));
    }

    // Get bookings by status
    @GetMapping("/status/{status}")
    public ResponseEntity<List<Booking>> getBookingsByStatus(
            @AuthenticationPrincipal User user,
            @PathVariable BookingStatus status
    ) {
        return ResponseEntity.ok(bookingService.getUserBookingsByStatus(user.getId(), status));
    }

    // Get booking history
    @GetMapping("/history")
    public ResponseEntity<List<Booking>> getBookingHistory(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(bookingService.getBookingHistory(user.getId()));
    }

    // Get booking by ID
    @GetMapping("/{id}")
    public ResponseEntity<Booking> getBookingById(@PathVariable Long id) {
        return ResponseEntity.ok(bookingService.getBookingById(id));
    }

    // Get booking by booking number
    @GetMapping("/number/{bookingNumber}")
    public ResponseEntity<Booking> getBookingByNumber(@PathVariable String bookingNumber) {
        return ResponseEntity.ok(bookingService.getBookingByNumber(bookingNumber));
    }

    // Check car availability
    @GetMapping("/check-availability")
    public ResponseEntity<Map<String, Boolean>> checkAvailability(
            @RequestParam Long carId,
            @RequestParam LocalDate startDate,
            @RequestParam LocalDate endDate
    ) {
        boolean available = bookingService.isCarAvailable(carId, startDate, endDate);
        return ResponseEntity.ok(Map.of("available", available));
    }

    // Create booking
    @PostMapping
    public ResponseEntity<?> createBooking(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody BookingRequest request
    ) {
        try {
            Booking booking = bookingService.createBooking(request, user.getId());
            return ResponseEntity.ok(booking);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Cancel booking
    @PostMapping("/{id}/cancel")
    public ResponseEntity<?> cancelBooking(
            @PathVariable Long id,
            @RequestBody(required = false) Map<String, String> body
    ) {
        try {
            String reason = body != null ? body.get("reason") : "User cancelled";
            Booking booking = bookingService.cancelBooking(id, reason);
            return ResponseEntity.ok(booking);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
