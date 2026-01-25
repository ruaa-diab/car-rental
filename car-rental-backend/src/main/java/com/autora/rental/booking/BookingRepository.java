package com.autora.rental.booking;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Long> {

    // Find all bookings for a user
    List<Booking> findByUserIdOrderByCreatedAtDesc(Long userId);

    // Find by booking number
    Optional<Booking> findByBookingNumber(String bookingNumber);

    // Find by status
    List<Booking> findByUserIdAndStatus(Long userId, BookingStatus status);

    // Find active bookings for a car (to check availability)
    @Query("SELECT b FROM Booking b WHERE b.car.id = :carId AND b.status IN ('UPCOMING', 'ACTIVE') " +
           "AND NOT (b.returnDate < :startDate OR b.pickupDate > :endDate)")
    List<Booking> findOverlappingBookings(@Param("carId") Long carId,
                                          @Param("startDate") LocalDate startDate,
                                          @Param("endDate") LocalDate endDate);

    // Count active bookings for a car
    @Query("SELECT COUNT(b) FROM Booking b WHERE b.car.id = :carId AND b.status IN ('UPCOMING', 'ACTIVE')")
    Long countActiveBookingsForCar(@Param("carId") Long carId);

    // Find bookings that need status update (pickup date is today)
    @Query("SELECT b FROM Booking b WHERE b.status = 'UPCOMING' AND b.pickupDate <= :today")
    List<Booking> findBookingsToActivate(@Param("today") LocalDate today);

    // Find bookings that need completion (return date has passed)
    @Query("SELECT b FROM Booking b WHERE b.status = 'ACTIVE' AND b.returnDate < :today")
    List<Booking> findBookingsToComplete(@Param("today") LocalDate today);

    // Booking history (completed + cancelled)
    @Query("SELECT b FROM Booking b WHERE b.user.id = :userId AND b.status IN ('COMPLETED', 'CANCELLED') ORDER BY b.createdAt DESC")
    List<Booking> findBookingHistory(@Param("userId") Long userId);

    // Count by status
    @Query("SELECT COUNT(b) FROM Booking b WHERE b.status = :status")
    long countByStatus(@Param("status") BookingStatus status);

    // Calculate revenue by date range
    @Query("SELECT SUM(b.totalPrice) FROM Booking b WHERE b.status = 'COMPLETED' AND b.createdAt BETWEEN :startDate AND :endDate")
    Double calculateRevenueByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    // Count bookings by date range
    @Query("SELECT COUNT(b) FROM Booking b WHERE b.createdAt BETWEEN :startDate AND :endDate")
    Long countByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    // Count by status and date range
    @Query("SELECT COUNT(b) FROM Booking b WHERE b.status = :status AND b.createdAt BETWEEN :startDate AND :endDate")
    Long countByStatusAndDateRange(@Param("status") BookingStatus status, @Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}
