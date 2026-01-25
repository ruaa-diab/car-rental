package com.autora.rental.booking;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingRequest {

    @NotNull(message = "Car ID is required")
    private Long carId;

    @NotNull(message = "Pickup branch ID is required")
    private Long pickupBranchId;

    @NotNull(message = "Return branch ID is required")
    private Long returnBranchId;

    @NotNull(message = "Pickup date is required")
    private LocalDate pickupDate;

    @NotNull(message = "Return date is required")
    private LocalDate returnDate;

    private String pickupTime;  // Accept as string e.g. "10:00 AM"

    private String returnTime;  // Accept as string e.g. "5:00 PM"

    // Payment details
    @NotNull(message = "Card number is required")
    private String cardNumber;

    @NotNull(message = "Card holder name is required")
    private String cardHolderName;

    @NotNull(message = "Card brand is required")
    private String cardBrand;  // VISA, MASTERCARD, etc.

    @NotNull(message = "Expiry date is required")
    private String expiryDate;  // MM/YY

    @NotNull(message = "CVV is required")
    private String cvv;
}
