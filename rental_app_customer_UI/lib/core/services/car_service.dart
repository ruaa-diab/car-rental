import 'api_service.dart';

class CarService {
  static CarService? _instance;
  final ApiService _api = ApiService.instance;

  CarService._();

  factory CarService() {
    _instance ??= CarService._();
    return _instance!;
  }

  static CarService get instance {
    _instance ??= CarService._();
    return _instance!;
  }
// Get ALL cars for manager (includes rented & maintenance)
Future<List<dynamic>> getAllCarsManager() async {
  final response = await _api.get('/cars');
  return response is List ? response : [];
}

  // Get all cars (public)
  Future<List<dynamic>> getAllCars() async {
    final response = await _api.get('/cars/public');
    return response is List ? response : [];
  }

  // Get car by ID (public)
  Future<Map<String, dynamic>> getCarById(int id) async {
    return await _api.get('/cars/public/$id');
  }

  // Search cars by name
  Future<List<dynamic>> searchCars(String query) async {
    final response = await _api.get(
      '/cars/public/search?query=${Uri.encodeComponent(query)}',
    );
    return response is List ? response : [];
  }

  // Get available cars only
  Future<List<dynamic>> getAvailableCars() async {
    final response = await _api.get('/cars/public');
    return response is List ? response : [];
  }

  // Get cars by type
  Future<List<dynamic>> getCarsByType(String type) async {
    final response = await _api.get('/cars/public/type/$type');
    return response is List ? response : [];
  }

  // Get cars by brand
  Future<List<dynamic>> getCarsByBrand(String brand) async {
    final response = await _api.get(
      '/cars/public/brand/${Uri.encodeComponent(brand)}',
    );
    return response is List ? response : [];
  }

  // Get available cars at a branch
  Future<List<dynamic>> getCarsByBranch(int branchId) async {
    final response = await _api.get('/cars/public/branch/$branchId');
    return response is List ? response : [];
  }

  // ============ MANAGER ENDPOINTS ============

  // Add a new car (Manager only)
  Future<Map<String, dynamic>> addCar(Map<String, dynamic> carData) async {
    return await _api.post('/cars', body: carData);
  }

  // Update a car (Manager only)
  Future<Map<String, dynamic>> updateCar(int id, Map<String, dynamic> carData) async {
    return await _api.put('/cars/$id', body: carData);
  }

  // Delete a car (Manager only)
  Future<void> deleteCar(int id) async {
    await _api.delete('/cars/$id');
  }
}
