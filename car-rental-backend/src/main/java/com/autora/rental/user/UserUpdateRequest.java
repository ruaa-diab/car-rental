package com.autora.rental.user;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserUpdateRequest {
    private String fullName;

    @Size(min = 13, max = 13, message = "Phone number must be exactly 13 characters")
    @Pattern(regexp = "^\\+97[02]\\d{9}$", message = "Phone must start with +970 or +972 followed by 9 digits")
    private String phone;

    private String profileImage;
}
