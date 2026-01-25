package com.autora.rental.user;

import com.autora.rental.token.Token;
import jakarta.persistence.*;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "users")
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String fullName;

    @Column(unique = true)
    private String email;

    @Column(unique = true, length = 13)
    @Size(min = 13, max = 13, message = "Phone number must be exactly 13 characters")
    @Pattern(regexp = "^\\+97[02]\\d{9}$", message = "Phone must start with +970 or +972 followed by 9 digits")
    private String phone;

    private String password;

    @Enumerated(EnumType.STRING)
    private Role role;

    private String profileImageUrl;

    private LocalDateTime createdAt;

    // Employee-specific fields (nullable for regular users)
    private LocalDate hireDate;

    private String status;  // active, on_leave, inactive

    private String position;  // Job title

    private String department;

    @OneToMany(mappedBy = "user")
    private List<Token> tokens;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
    
    // Helper method for compatibility if needed
    public String getProfileImage() {
        return profileImageUrl;
    }
}