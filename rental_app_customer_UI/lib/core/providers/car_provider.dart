import 'package:flutter/foundation.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';
import '../services/api_service.dart';

class CarProvider extends ChangeNotifier {
  final CarService _carService = CarService();

  List<CarModel> _cars = [];
  List<CarModel> _filteredCars = [];
  List<String> _brands = [];
  CarModel? _selectedCar;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CarModel> get cars => _cars;
  List<CarModel> get filteredCars => _filteredCars.isEmpty ? _cars : _filteredCars;
  List<String> get brands => _brands;
  CarModel? get selectedCar => _selectedCar;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all cars
  Future<void> loadCars() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _carService.getAllCars();
      _cars = response.map((json) => CarModel.fromJson(json)).toList();
      _filteredCars = [];
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load cars';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load all brands
  Future<void> loadBrands() async {
    try {
      // Extract unique brands from cars
      _brands = _cars.map((c) => c.brand).toSet().toList();
      notifyListeners();
    } catch (e) {
      // Ignore brand loading errors
    }
  }

  // Get car by ID
  Future<CarModel?> getCarById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _carService.getCarById(id);
      _selectedCar = CarModel.fromJson(response);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load car details';
    }

    _isLoading = false;
    notifyListeners();
    return _selectedCar;
  }

  // Search cars
  Future<void> searchCars(String query) async {
    if (query.isEmpty) {
      _filteredCars = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _carService.searchCars(query);
      _filteredCars = response.map((json) => CarModel.fromJson(json)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Search failed';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Filter cars by type
  Future<void> filterByType(String type) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _carService.getCarsByType(type);
      _filteredCars = response.map((json) => CarModel.fromJson(json)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Filter failed';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Filter cars by brand
  Future<void> filterByBrand(String brand) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _carService.getCarsByBrand(brand);
      _filteredCars = response.map((json) => CarModel.fromJson(json)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Filter failed';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Filter by multiple criteria (local filtering)
  void filterCars({
    String? type,
    String? brand,
    String? transmission,
    String? fuel,
    double? minPrice,
    double? maxPrice,
  }) {
    _filteredCars = _cars.where((car) {
      if (type != null && car.type != type) return false;
      if (brand != null && car.brand != brand) return false;
      if (transmission != null && car.transmission != transmission) return false;
      if (fuel != null && car.fuelType != fuel) return false;
      if (minPrice != null && car.pricePerDay < minPrice) return false;
      if (maxPrice != null && car.pricePerDay > maxPrice) return false;
      return true;
    }).toList();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _filteredCars = [];
    notifyListeners();
  }

  // Set selected car
  void setSelectedCar(CarModel car) {
    _selectedCar = car;
    notifyListeners();
  }

  // Clear selected car
  void clearSelectedCar() {
    _selectedCar = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
