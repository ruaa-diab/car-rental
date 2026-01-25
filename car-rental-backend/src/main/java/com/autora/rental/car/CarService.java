package com.autora.rental.car;

import com.autora.rental.notification.NotificationService;
import com.autora.rental.notification.NotificationType;
import com.autora.rental.user.User;
import com.autora.rental.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CarService {

    private final CarRepository carRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    // Get all available cars
    public List<Car> getAllAvailableCars() {
        return carRepository.findAllAvailable();
    }

    // Get car by ID
    public Car getCarById(Long id) {
        return carRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Car not found with id: " + id));
    }

    // Search cars
    public List<Car> searchCars(String query) {
        return carRepository.searchCars(query);
    }

    // Get cars by type
    public List<Car> getCarsByType(CarType type) {
        return carRepository.findByTypeAndIsActiveTrueAndAvailableQuantityGreaterThan(type, 0);
    }

    // Get cars by brand
    public List<Car> getCarsByBrand(String brand) {
        return carRepository.findByBrandContainingIgnoreCaseAndIsActiveTrueAndAvailableQuantityGreaterThan(brand, 0);
    }
// Get ALL cars (for manager)
public List<Car> getAllCars() {
    return carRepository.findAll();
}

    // Get cars by branch
    public List<Car> getCarsByBranch(Long branchId) {
        return carRepository.findByBranchId(branchId);
    }

    // Get cars by fuel type
    public List<Car> getCarsByFuel(FuelType fuel) {
        return carRepository.findByFuelAndIsActiveTrueAndAvailableQuantityGreaterThan(fuel, 0);
    }

    // Get cars by transmission
    public List<Car> getCarsByTransmission(TransmissionType transmission) {
        return carRepository.findByTransmissionAndIsActiveTrueAndAvailableQuantityGreaterThan(transmission, 0);
    }

    // Get cars by price range
    public List<Car> getCarsByPriceRange(BigDecimal minPrice, BigDecimal maxPrice) {
        return carRepository.findByPriceRange(minPrice, maxPrice);
    }

    // Get all unique brands
    public List<String> getAllBrands() {
        return carRepository.findAllBrands();
    }

    // Filter cars with multiple criteria
    public List<Car> filterCars(
            String type,
            String brand,
            String transmission,
            String fuel,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Long branchId,
            Boolean availableOnly
    ) {
        List<Car> cars = getAllAvailableCars();

        if (type != null && !type.isEmpty()) {
            CarType carType = CarType.valueOf(type.toUpperCase());
            cars = cars.stream().filter(c -> c.getType() == carType).toList();
        }
        if (brand != null && !brand.isEmpty()) {
            cars = cars.stream().filter(c -> c.getBrand().equalsIgnoreCase(brand)).toList();
        }
        if (transmission != null && !transmission.isEmpty()) {
            TransmissionType transType = TransmissionType.valueOf(transmission.toUpperCase());
            cars = cars.stream().filter(c -> c.getTransmission() == transType).toList();
        }
        if (fuel != null && !fuel.isEmpty()) {
            FuelType fuelType = FuelType.valueOf(fuel.toUpperCase());
            cars = cars.stream().filter(c -> c.getFuel() == fuelType).toList();
        }
        if (minPrice != null) {
            cars = cars.stream()
                    .filter(c -> c.getPricePerDay().compareTo(minPrice) >= 0)
                    .toList();
        }
        if (maxPrice != null) {
            cars = cars.stream()
                    .filter(c -> c.getPricePerDay().compareTo(maxPrice) <= 0)
                    .toList();
        }
        if (branchId != null) {
            cars = cars.stream()
                    .filter(c -> c.getAvailableBranches().stream()
                            .anyMatch(b -> b.getId().equals(branchId)))
                    .toList();
        }

        // لو حابة تضيفي فلترة لـ availableOnly لاحقاً
        return cars;
    }

    // ================== ADMIN METHODS ================== //

    // Admin: Add new car
    @Transactional
    public Car addCar(Car car) {
        // default values و validation بسيطة
        if (car.getTotalQuantity() == null) {
            car.setTotalQuantity(0);
        }
        if (car.getAvailableQuantity() == null || car.getAvailableQuantity() < 0) {
            car.setAvailableQuantity(car.getTotalQuantity());
        }

        if (car.getPricePerDay() == null || car.getPricePerDay().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Price per day must be a positive value");
        }

        if (car.getTotalQuantity() < 0) {
            throw new IllegalArgumentException("Total quantity cannot be negative");
        }

        if (car.getAvailableQuantity() > car.getTotalQuantity()) {
            car.setAvailableQuantity(car.getTotalQuantity());
        }

        // لو isActive مش محددة نخليها true
        if (!car.isActive()) {
            car.setActive(true);
        }

        Car savedCar = carRepository.save(car);

        // Notify all users about new car
        notifyAllUsersAboutNewCar(savedCar);

        return savedCar;
    }

    // Admin: Update car
    @Transactional
    public Car updateCar(Long id, Car carDetails) {
        Car car = getCarById(id);

        car.setName(carDetails.getName());
        car.setBrand(carDetails.getBrand());
        car.setModel(carDetails.getModel());
        car.setYear(carDetails.getYear());
        car.setType(carDetails.getType());
        car.setTransmission(carDetails.getTransmission());
        car.setFuel(carDetails.getFuel());
        car.setPricePerDay(carDetails.getPricePerDay());
        car.setSeats(carDetails.getSeats());
        car.setColor(carDetails.getColor());
        car.setImageUrl(carDetails.getImageUrl());
        car.setDescription(carDetails.getDescription());
        car.setTotalQuantity(carDetails.getTotalQuantity());
        car.setAvailableQuantity(carDetails.getAvailableQuantity());
        car.setActive(carDetails.isActive());

        // نفس التحقق المستخدم في addCar
        if (car.getTotalQuantity() == null) {
            car.setTotalQuantity(0);
        }
        if (car.getAvailableQuantity() == null || car.getAvailableQuantity() < 0) {
            car.setAvailableQuantity(car.getTotalQuantity());
        }
        if (car.getTotalQuantity() < 0) {
            throw new IllegalArgumentException("Total quantity cannot be negative");
        }
        if (car.getAvailableQuantity() > car.getTotalQuantity()) {
            car.setAvailableQuantity(car.getTotalQuantity());
        }
        if (car.getPricePerDay() == null || car.getPricePerDay().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Price per day must be a positive value");
        }

        return carRepository.save(car);
    }

    // Admin: Delete car (soft delete)
    @Transactional
    public void deleteCar(Long id) {
        Car car = getCarById(id);
        car.setActive(false);
        carRepository.save(car);
    }

    // Notify all users about new car
    private void notifyAllUsersAboutNewCar(Car car) {
        List<User> allUsers = userRepository.findAll();
        for (User user : allUsers) {
            notificationService.createNotification(
                    user,
                    "New Car Available!",
                    "Check out our new " + car.getName() + " - " + car.getType()
                            + " starting at $" + car.getPricePerDay() + "/day",
                    NotificationType.NEW_CAR,
                    car.getId()
            );
        }
    }
}
