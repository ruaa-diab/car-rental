package com.autora.rental.car;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/cars")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CarController {

    private final CarService carService;

    // ============ PUBLIC ENDPOINTS ============

    @GetMapping("/public")
    public ResponseEntity<List<Car>> getAllAvailableCars() {
        return ResponseEntity.ok(carService.getAllAvailableCars());
    }
// ============ MANAGER ENDPOINTS ============

@GetMapping
@PreAuthorize("hasRole('MANAGER')")
public ResponseEntity<List<Car>> getAllCars() {
    return ResponseEntity.ok(carService.getAllCars());
}

    @GetMapping("/public/{id}")
    public ResponseEntity<Car> getCarById(@PathVariable Long id) {
        return ResponseEntity.ok(carService.getCarById(id));
    }

    @GetMapping("/public/search")
    public ResponseEntity<List<Car>> searchCars(@RequestParam String query) {
        return ResponseEntity.ok(carService.searchCars(query));
    }

    @GetMapping("/public/type/{type}")
    public ResponseEntity<List<Car>> getCarsByType(@PathVariable CarType type) {
        return ResponseEntity.ok(carService.getCarsByType(type));
    }

    @GetMapping("/public/brand/{brand}")
    public ResponseEntity<List<Car>> getCarsByBrand(@PathVariable String brand) {
        return ResponseEntity.ok(carService.getCarsByBrand(brand));
    }

    @GetMapping("/public/branch/{branchId}")
    public ResponseEntity<List<Car>> getCarsByBranch(@PathVariable Long branchId) {
        return ResponseEntity.ok(carService.getCarsByBranch(branchId));
    }

    @GetMapping("/public/fuel/{fuel}")
    public ResponseEntity<List<Car>> getCarsByFuel(@PathVariable FuelType fuel) {
        return ResponseEntity.ok(carService.getCarsByFuel(fuel));
    }

    @GetMapping("/public/transmission/{transmission}")
    public ResponseEntity<List<Car>> getCarsByTransmission(@PathVariable TransmissionType transmission) {
        return ResponseEntity.ok(carService.getCarsByTransmission(transmission));
    }

    @GetMapping("/public/price-range")
    public ResponseEntity<List<Car>> getCarsByPriceRange(
            @RequestParam BigDecimal minPrice,
            @RequestParam BigDecimal maxPrice
    ) {
        return ResponseEntity.ok(carService.getCarsByPriceRange(minPrice, maxPrice));
    }

    @GetMapping("/public/brands")
    public ResponseEntity<List<String>> getAllBrands() {
        return ResponseEntity.ok(carService.getAllBrands());
    }

    @GetMapping("/public/filter")
    public ResponseEntity<List<Car>> filterCars(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String brand,
            @RequestParam(required = false) String transmission,
            @RequestParam(required = false) String fuel,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) Long branchId,
            @RequestParam(required = false) Boolean availableOnly
    ) {
        return ResponseEntity.ok(carService.filterCars(type, brand, transmission, fuel, minPrice, maxPrice, branchId, availableOnly));
    }

    // ============ MANAGER ENDPOINTS ============

    @PostMapping
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<Car> addCar(@RequestBody Car car) {
        return ResponseEntity.ok(carService.addCar(car));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<Car> updateCar(@PathVariable Long id, @RequestBody Car car) {
        return ResponseEntity.ok(carService.updateCar(id, car));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<?> deleteCar(@PathVariable Long id) {
        carService.deleteCar(id);
        return ResponseEntity.ok(Map.of("message", "Car deleted successfully"));
    }
}
