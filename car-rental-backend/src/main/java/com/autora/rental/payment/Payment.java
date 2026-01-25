package com.autora.rental.payment;

import com.autora.rental.booking.Booking;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "payments")
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false)
    private Booking booking;

    @Column(nullable = false)
    private String transactionId;  // Mock transaction ID

    @Column(nullable = false)
    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentMethod paymentMethod;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentStatus status;

    // Masked card details (for display only - never store full card numbers!)
    private String cardLastFour;  // e.g., "4242"
    private String cardBrand;     // e.g., "VISA", "MASTERCARD"
    private String cardHolderName;

    private LocalDateTime paidAt;

    private LocalDateTime refundedAt;

    private String refundReason;

    @PrePersist
    protected void onCreate() {
        if (transactionId == null) {
            transactionId = generateTransactionId();
        }
        if (status == null) {
            status = PaymentStatus.PENDING;
        }
    }

    private String generateTransactionId() {
        return "TXN" + System.currentTimeMillis() + (int)(Math.random() * 1000);
    }
}
