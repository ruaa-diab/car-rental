package com.autora.rental.notification;

import com.autora.rental.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;

    // Get all notifications for user
    public List<Notification> getUserNotifications(Long userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    // Get unread notifications
    public List<Notification> getUnreadNotifications(Long userId) {
        return notificationRepository.findByUserIdAndIsReadFalseOrderByCreatedAtDesc(userId);
    }

    // Get unread count
    public Long getUnreadCount(Long userId) {
        return notificationRepository.countByUserIdAndIsReadFalse(userId);
    }

    // Mark notification as read
    @Transactional
    public Notification markAsRead(Long notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Notification not found"));
        notification.markAsRead();
        return notificationRepository.save(notification);
    }

    // Mark all as read
    @Transactional
    public void markAllAsRead(Long userId) {
        notificationRepository.markAllAsRead(userId);
    }

    // Create notification
    @Transactional
    public Notification createNotification(User user, String title, String message, NotificationType type, Long referenceId) {
        Notification notification = Notification.builder()
                .user(user)
                .title(title)
                .message(message)
                .type(type)
                .referenceId(referenceId)
                .build();
        return notificationRepository.save(notification);
    }

    // Create booking notification
    public void sendBookingConfirmation(User user, String bookingNumber, String carName) {
        createNotification(
                user,
                "Booking Confirmed!",
                "Your booking #" + bookingNumber + " for " + carName + " has been confirmed. Check your bookings for details.",
                NotificationType.BOOKING_CONFIRMED,
                null
        );
    }

    // Create booking cancellation notification
    public void sendBookingCancellation(User user, String bookingNumber) {
        createNotification(
                user,
                "Booking Cancelled",
                "Your booking #" + bookingNumber + " has been cancelled.",
                NotificationType.BOOKING_CANCELLED,
                null
        );
    }

    // Create booking completion notification
    public void sendBookingCompleted(User user, String bookingNumber) {
        createNotification(
                user,
                "Trip Completed!",
                "Thank you for using Autora! Your trip #" + bookingNumber + " has been completed. We hope to see you again soon!",
                NotificationType.BOOKING_COMPLETED,
                null
        );
    }

    // Create special offer notification
    public void sendSpecialOffer(User user, String offerTitle, String offerDescription) {
        createNotification(
                user,
                offerTitle,
                offerDescription,
                NotificationType.SPECIAL_OFFER,
                null
        );
    }

    // Delete notification
    @Transactional
    public void deleteNotification(Long notificationId) {
        notificationRepository.deleteById(notificationId);
    }
}
