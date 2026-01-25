package com.autora.rental.favorite;

import com.autora.rental.car.Car;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    List<Favorite> findByUserIdOrderByCreatedAtDesc(Long userId);

    Optional<Favorite> findByUserIdAndCarId(Long userId, Long carId);

    boolean existsByUserIdAndCarId(Long userId, Long carId);

    void deleteByUserIdAndCarId(Long userId, Long carId);

    @Query("SELECT f.car FROM Favorite f WHERE f.user.id = :userId")
    List<Car> findFavoriteCarsByUserId(@Param("userId") Long userId);
}
