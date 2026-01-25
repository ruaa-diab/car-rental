package com.autora.rental.booking;

import com.autora.rental.branch.Branch;
import com.autora.rental.branch.BranchRepository;
import com.autora.rental.car.Car;
import com.autora.rental.car.CarRepository;
import com.autora.rental.notification.NotificationService;
import com.autora.rental.payment.Payment;
import com.autora.rental.payment.PaymentMethod;
import com.autora.rental.payment.PaymentRepository;
import com.autora.rental.payment.PaymentStatus;
import com.autora.rental.user.User;
import com.autora.rental.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BookingService {

    private final BookingRepository bookingRepository;
    private final CarRepository carRepository;
    private final BranchRepository branchRepository;
    private final UserRepository userRepository;
    private final PaymentRepository paymentRepository;
    private final NotificationService notificationService;

    // Get user bookings
    public List<Booking> getUserBookings(Long userId) {
        return bookingRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    // Get bookings by status
    public List<Booking> getUserBookingsByStatus(Long userId, BookingStatus status) {
        return bookingRepository.findByUserIdAndStatus(userId, status);
    }

    // Get booking history
    public List<Booking> getBookingHistory(Long userId) {
        return bookingRepository.findBookingHistory(userId);
    }

    // Get booking by ID
    public Booking getBookingById(Long id) {
        return bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking not found"));
    }

    // Get booking by booking number
    public Booking getBookingByNumber(String bookingNumber) {
        return bookingRepository.findByBookingNumber(bookingNumber)
                .orElseThrow(() -> new RuntimeException("Booking not found"));
    }

    // Check car availability for dates
    public boolean isCarAvailable(Long carId, LocalDate startDate, LocalDate endDate) {
        Car car = carRepository.findById(carId)
                .orElseThrow(() -> new RuntimeException("Car not found"));

        if (!car.isAvailable()) {
            return false;
        }

        List<Booking> overlappingBookings = bookingRepository.findOverlappingBookings(carId, startDate, endDate);
        return overlappingBookings.size() < car.getAvailableQuantity();
    }

    // Create booking with payment
    @Transactional
    public Booking createBooking(BookingRequest request, Long userId) {
        // Validate user
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Validate car
        Car car = carRepository.findById(request.getCarId())
                .orElseThrow(() -> new RuntimeException("Car not found"));

        // Check availability
        if (!isCarAvailable(request.getCarId(), request.getPickupDate(), request.getReturnDate())) {
            throw new RuntimeException("Car is not available for selected dates");
        }

        // Validate branches
        Branch pickupBranch = branchRepository.findById(request.getPickupBranchId())
                .orElseThrow(() -> new RuntimeException("Pickup branch not found"));

        Branch returnBranch = branchRepository.findById(request.getReturnBranchId())
                .orElseThrow(() -> new RuntimeException("Return branch not found"));

        // Create booking
        Booking booking = Booking.builder()
                .user(user)
                .car(car)
                .pickupBranch(pickupBranch)
                .returnBranch(returnBranch)
                .pickupDate(request.getPickupDate())
                .returnDate(request.getReturnDate())
                .pickupTime(parseTime(request.getPickupTime()))
                .returnTime(parseTime(request.getReturnTime()))
                .pricePerDay(car.getPricePerDay())
                .status(BookingStatus.UPCOMING)
                .build();

        booking.calculateTotalDays();
        booking.calculateTotalPrice();

        Booking savedBooking = bookingRepository.save(booking);

        // Process payment
        Payment payment = processPayment(savedBooking, request);
        savedBooking.setPayment(payment);

        // Decrement car quantity
        car.decrementQuantity();
        carRepository.save(car);

        // Send notification
        notificationService.sendBookingConfirmation(user, savedBooking.getBookingNumber(), car.getName());

        return savedBooking;
    }

    // Process mock payment
    private Payment processPayment(Booking booking, BookingRequest request) {
        // Mock payment processing - always succeeds
        Payment payment = Payment.builder()
                .booking(booking)
                .amount(booking.getTotalPrice())
                .paymentMethod(PaymentMethod.valueOf(request.getCardBrand().toUpperCase()))
                .cardLastFour(request.getCardNumber().substring(request.getCardNumber().length() - 4))
                .cardBrand(request.getCardBrand())
                .cardHolderName(request.getCardHolderName())
                .status(PaymentStatus.COMPLETED)
                .paidAt(LocalDateTime.now())
                .build();

        return paymentRepository.save(payment);
    }

    // Cancel booking
    @Transactional
    public Booking cancelBooking(Long bookingId, String reason) {
        Booking booking = getBookingById(bookingId);

        if (!booking.canCancel()) {
            throw new RuntimeException("This booking cannot be cancelled");
        }

        booking.setStatus(BookingStatus.CANCELLED);
        booking.setCancelledAt(LocalDateTime.now());
        booking.setCancellationReason(reason);

        // Increment car quantity
        Car car = booking.getCar();
        car.incrementQuantity();
        carRepository.save(car);

        // Process refund (mock)
        Payment payment = booking.getPayment();
        if (payment != null) {
            payment.setStatus(PaymentStatus.REFUNDED);
            payment.setRefundedAt(LocalDateTime.now());
            payment.setRefundReason(reason);
            paymentRepository.save(payment);
        }

        // Send notification
        notificationService.sendBookingCancellation(booking.getUser(), booking.getBookingNumber());

        return bookingRepository.save(booking);
    }

    // Scheduled task to update booking statuses
    @Scheduled(cron = "0 0 0 * * *") // Run daily at midnight
    @Transactional
    public void updateBookingStatuses() {
        LocalDate today = LocalDate.now();

        // Activate bookings where pickup date is today
        List<Booking> toActivate = bookingRepository.findBookingsToActivate(today);
        for (Booking booking : toActivate) {
            booking.setStatus(BookingStatus.ACTIVE);
            bookingRepository.save(booking);
        }

        // Complete bookings where return date has passed
        List<Booking> toComplete = bookingRepository.findBookingsToComplete(today);
        for (Booking booking : toComplete) {
            booking.setStatus(BookingStatus.COMPLETED);

            // Increment car quantity
            Car car = booking.getCar();
            car.incrementQuantity();
            carRepository.save(car);

            // Send notification
            notificationService.sendBookingCompleted(booking.getUser(), booking.getBookingNumber());

            bookingRepository.save(booking);
        }
    }

    // Parse time string to LocalTime (handles formats like "10:00 AM", "14:00", etc.)
    private LocalTime parseTime(String timeStr) {
        if (timeStr == null || timeStr.isEmpty()) {
            return LocalTime.of(10, 0); // Default to 10:00 AM
        }
        try {
            // Try to parse as 24-hour format first (HH:mm)
            if (timeStr.matches("\\d{1,2}:\\d{2}")) {
                return LocalTime.parse(timeStr.length() == 4 ? "0" + timeStr : timeStr);
            }
            // Handle 12-hour format with AM/PM
            timeStr = timeStr.toUpperCase().trim();
            boolean isPM = timeStr.contains("PM");
            timeStr = timeStr.replace("AM", "").replace("PM", "").trim();
            String[] parts = timeStr.split(":");
            int hour = Integer.parseInt(parts[0].trim());
            int minute = parts.length > 1 ? Integer.parseInt(parts[1].trim()) : 0;

            if (isPM && hour != 12) hour += 12;
            if (!isPM && hour == 12) hour = 0;

            return LocalTime.of(hour, minute);
        } catch (Exception e) {
            return LocalTime.of(10, 0); // Default fallback
        }
    }
}
