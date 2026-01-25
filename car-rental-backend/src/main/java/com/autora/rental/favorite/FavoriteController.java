package com.autora.rental.favorite;

import com.autora.rental.car.Car;
import com.autora.rental.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/favorites")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FavoriteController {

    private final FavoriteService favoriteService;

    // Get user's favorites
    @GetMapping
    public ResponseEntity<List<Car>> getUserFavorites(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(favoriteService.getUserFavorites(user.getId()));
    }

    // Check if car is favorite
    @GetMapping("/{carId}/check")
    public ResponseEntity<Map<String, Boolean>> isFavorite(
            @AuthenticationPrincipal User user,
            @PathVariable Long carId
    ) {
        boolean isFav = favoriteService.isFavorite(user.getId(), carId);
        return ResponseEntity.ok(Map.of("isFavorite", isFav));
    }

    // Add to favorites
    @PostMapping("/{carId}")
    public ResponseEntity<?> addToFavorites(
            @AuthenticationPrincipal User user,
            @PathVariable Long carId
    ) {
        try {
            favoriteService.addToFavorites(user.getId(), carId);
            return ResponseEntity.ok(Map.of("message", "Added to favorites"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Remove from favorites
    @DeleteMapping("/{carId}")
    public ResponseEntity<?> removeFromFavorites(
            @AuthenticationPrincipal User user,
            @PathVariable Long carId
    ) {
        try {
            favoriteService.removeFromFavorites(user.getId(), carId);
            return ResponseEntity.ok(Map.of("message", "Removed from favorites"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Toggle favorite status
    @PostMapping("/{carId}/toggle")
    public ResponseEntity<Map<String, Boolean>> toggleFavorite(
            @AuthenticationPrincipal User user,
            @PathVariable Long carId
    ) {
        boolean isNowFavorite = favoriteService.toggleFavorite(user.getId(), carId);
        return ResponseEntity.ok(Map.of("isFavorite", isNowFavorite));
    }
}
