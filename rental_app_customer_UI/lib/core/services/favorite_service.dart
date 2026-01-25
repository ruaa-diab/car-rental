import '../models/car_model.dart';
import 'api_service.dart';

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final ApiService _api = ApiService();

  // Get all user's favorite cars
  Future<List<CarModel>> getFavorites() async {
    final response = await _api.get('/favorites');
    return (response as List).map((car) => CarModel.fromJson(car)).toList();
  }

  // Add car to favorites
  Future<void> addFavorite(int carId) async {
    await _api.post('/favorites/$carId');
  }

  // Remove car from favorites
  Future<void> removeFavorite(int carId) async {
    await _api.delete('/favorites/$carId');
  }

  // Toggle favorite status (add if not favorited, remove if favorited)
  Future<bool> toggleFavorite(int carId) async {
    final response = await _api.post('/favorites/$carId/toggle');
    return response['isFavorite'] == true;
  }

  // Check if car is favorited
  Future<bool> isFavorite(int carId) async {
    final response = await _api.get('/favorites/$carId/check');
    return response['isFavorite'] == true;
  }

  // Get favorite car IDs (for quick lookup)
  Future<Set<int>> getFavoriteIds() async {
    final favorites = await getFavorites();
    return favorites.map((car) => car.id).toSet();
  }
}
