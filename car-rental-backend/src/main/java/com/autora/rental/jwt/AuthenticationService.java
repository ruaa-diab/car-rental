package com.autora.rental.jwt;

import com.autora.rental.employee.Employee;
import com.autora.rental.employee.EmployeeRepository;
import com.autora.rental.token.Token;
import com.autora.rental.token.TokenRepository;
import com.autora.rental.token.TokenType;
import com.autora.rental.user.Role;
import com.autora.rental.user.User;
import com.autora.rental.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private final UserRepository userRepository;
    private final TokenRepository tokenRepository;
    private final EmployeeRepository employeeRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    /**
     * Register a new user
     */
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        // Check if email already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered");
        }

        // Check if phone already exists
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new RuntimeException("Phone number already registered");
        }

        // Create new user
        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .phone(request.getPhone())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(Role.USER)
                .build();

        User savedUser = userRepository.save(user);

        // Generate token
        String token = jwtService.generateToken(user);

        // Save token
        saveUserToken(savedUser, token);

        return AuthResponse.builder()
                .token(token)
                .email(savedUser.getEmail())
                .fullName(savedUser.getFullName())
                .phone(savedUser.getPhone())
                .userId(savedUser.getId())
                .role(savedUser.getRole().name())
                .message("Registration successful")
                .build();
    }

    /**
     * Authenticate user and return token
     */
    @Transactional
    public AuthResponse authenticate(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Revoke previous tokens
        revokeAllUserTokens(user);

        // Generate new token
        String token = jwtService.generateToken(user);

        // Save token
        saveUserToken(user, token);

        // Get employee ID if user is an employee or manager
        Long employeeId = null;
        if (user.getRole() == Role.EMPLOYEE || user.getRole() == Role.MANAGER) {
            employeeId = employeeRepository.findByUserId(user.getId())
                    .map(Employee::getId)
                    .orElse(null);
        }

        return AuthResponse.builder()
                .token(token)
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .userId(user.getId())
                .role(user.getRole().name())
                .employeeId(employeeId)
                .message("Login successful")
                .build();
    }

    /**
     * Save token for user
     */
    private void saveUserToken(User user, String token) {
        Token t = Token.builder()
                .user(user)
                .token(token)
                .tokenType(TokenType.BEARER)
                .expired(false)
                .revoked(false)
                .build();
        tokenRepository.save(t);
    }

    /**
     * Revoke all active tokens for user
     */
    private void revokeAllUserTokens(User user) {
        var validTokens = tokenRepository.findAllValidTokenByUser(user.getId());
        if (validTokens.isEmpty()) return;

        validTokens.forEach(t -> {
            t.setExpired(true);
            t.setRevoked(true);
        });
        tokenRepository.saveAll(validTokens);
    }
}
