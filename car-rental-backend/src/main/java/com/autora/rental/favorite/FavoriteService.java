package com.autora.rental.favorite;

import com.autora.rental.car.Car;
import com.autora.rental.car.CarRepository;
import com.autora.rental.user.User;
import com.autora.rental.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final UserRepository userRepository;
    private final CarRepository carRepository;

    // Get user's favorites
    public List<Car> getUserFavorites(Long userId) {
        return favoriteRepository.findFavoriteCarsByUserId(userId);
    }

    // Check if car is in favorites
    public boolean isFavorite(Long userId, Long carId) {
        return favoriteRepository.existsByUserIdAndCarId(userId, carId);
    }

    // Add to favorites
    @Transactional
    public Favorite addToFavorites(Long userId, Long carId) {
        if (isFavorite(userId, carId)) {
            throw new RuntimeException("Car is already in favorites");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Car car = carRepository.findById(carId)
                .orElseThrow(() -> new RuntimeException("Car not found"));

        Favorite favorite = Favorite.builder()
                .user(user)
                .car(car)
                .build();

        return favoriteRepository.save(favorite);
    }

    // Remove from favorites
    @Transactional
    public void removeFromFavorites(Long userId, Long carId) {
        if (!isFavorite(userId, carId)) {
            throw new RuntimeException("Car is not in favorites");
        }

        favoriteRepository.deleteByUserIdAndCarId(userId, carId);
    }

    // Toggle favorite status
    @Transactional
    public boolean toggleFavorite(Long userId, Long carId) {
        if (isFavorite(userId, carId)) {
            removeFromFavorites(userId, carId);
            return false;  // Removed from favorites
        } else {
            addToFavorites(userId, carId);
            return true;   // Added to favorites
        }
    }
}
