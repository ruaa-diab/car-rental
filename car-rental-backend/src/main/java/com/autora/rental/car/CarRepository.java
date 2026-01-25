package com.autora.rental.car;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CarRepository extends JpaRepository<Car, Long> {

    // Find all available cars (quantity > 0 and active)
    @Query("SELECT c FROM Car c WHERE c.isActive = true AND c.availableQuantity > 0")
    List<Car> findAllAvailable();

    // Find by type
    List<Car> findByTypeAndIsActiveTrueAndAvailableQuantityGreaterThan(CarType type, Integer quantity);

    // Find by brand
    List<Car> findByBrandContainingIgnoreCaseAndIsActiveTrueAndAvailableQuantityGreaterThan(String brand, Integer quantity);

    // Search by name
    @Query("SELECT c FROM Car c WHERE c.isActive = true AND c.availableQuantity > 0 AND " +
           "(LOWER(c.name) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(c.brand) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(c.model) LIKE LOWER(CONCAT('%', :search, '%')))")
    List<Car> searchCars(@Param("search") String search);

    // Find cars by branch
    @Query("SELECT c FROM Car c JOIN c.availableBranches b WHERE b.id = :branchId AND c.isActive = true AND c.availableQuantity > 0")
    List<Car> findByBranchId(@Param("branchId") Long branchId);

    // Find by fuel type
    List<Car> findByFuelAndIsActiveTrueAndAvailableQuantityGreaterThan(FuelType fuel, Integer quantity);

    // Find by transmission
    List<Car> findByTransmissionAndIsActiveTrueAndAvailableQuantityGreaterThan(TransmissionType transmission, Integer quantity);

    // Find by price range
    @Query("SELECT c FROM Car c WHERE c.isActive = true AND c.availableQuantity > 0 AND " +
           "c.pricePerDay BETWEEN :minPrice AND :maxPrice")
    List<Car> findByPriceRange(@Param("minPrice") java.math.BigDecimal minPrice,
                               @Param("maxPrice") java.math.BigDecimal maxPrice);

    // Get all unique brands
    @Query("SELECT DISTINCT c.brand FROM Car c WHERE c.isActive = true")
    List<String> findAllBrands();

    // Count available cars
    @Query("SELECT COUNT(c) FROM Car c WHERE c.isActive = true AND c.availableQuantity > 0")
    long countAvailableCars();
}
