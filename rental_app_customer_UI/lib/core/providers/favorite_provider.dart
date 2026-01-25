import 'package:flutter/foundation.dart';
import '../models/car_model.dart';
import '../services/favorite_service.dart';
import '../services/api_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();

  List<CarModel> _favorites = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CarModel> get favorites => _favorites;
  Set<int> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _favorites.length;

  // Check if a car is favorited (sync)
  bool isFavorite(int carId) => _favoriteIds.contains(carId);

  // Check if a car is favorited (async - for car_details_screen.dart)
  Future<bool> checkIsFavorite(int carId) async {
    // First check local cache
    if (_favoriteIds.contains(carId)) return true;
    
    // If favorites haven't been loaded yet, load them
    if (_favorites.isEmpty && _favoriteIds.isEmpty) {
      await loadFavorites();
    }
    
    return _favoriteIds.contains(carId);
  }

  // Load all favorites
  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await _favoriteService.getFavorites();
      _favoriteIds = _favorites.map((car) => car.id).toSet();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load favorites';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(int carId, {CarModel? car}) async {
    final wasFavorited = _favoriteIds.contains(carId);
    
    // Optimistic update
    if (wasFavorited) {
      _favoriteIds.remove(carId);
      _favorites.removeWhere((c) => c.id == carId);
    } else {
      _favoriteIds.add(carId);
      if (car != null) {
        _favorites.add(car);
      }
    }
    notifyListeners();

    try {
      final isFavorited = await _favoriteService.toggleFavorite(carId);
      
      // If server response differs from optimistic update, correct it
      if (isFavorited && !_favoriteIds.contains(carId)) {
        _favoriteIds.add(carId);
        if (car != null) _favorites.add(car);
      } else if (!isFavorited && _favoriteIds.contains(carId)) {
        _favoriteIds.remove(carId);
        _favorites.removeWhere((c) => c.id == carId);
      }
      
      notifyListeners();
      return isFavorited;
    } catch (e) {
      // Revert on error
      if (wasFavorited) {
        _favoriteIds.add(carId);
        if (car != null) _favorites.add(car);
      } else {
        _favoriteIds.remove(carId);
        _favorites.removeWhere((c) => c.id == carId);
      }
      notifyListeners();
      return wasFavorited;
    }
  }

  // Add to favorites
  Future<bool> addFavorite(int carId, {CarModel? car}) async {
    if (_favoriteIds.contains(carId)) return true;

    // Optimistic update
    _favoriteIds.add(carId);
    if (car != null) _favorites.add(car);
    notifyListeners();

    try {
      await _favoriteService.addFavorite(carId);
      return true;
    } catch (e) {
      // Revert on error
      _favoriteIds.remove(carId);
      _favorites.removeWhere((c) => c.id == carId);
      notifyListeners();
      return false;
    }
  }

  // Remove from favorites
  Future<bool> removeFavorite(int carId) async {
    if (!_favoriteIds.contains(carId)) return true;

    // Store for potential revert
    CarModel? car;
    try {
      car = _favorites.firstWhere((c) => c.id == carId);
    } catch (e) {
      car = null;
    }
    
    // Optimistic update
    _favoriteIds.remove(carId);
    _favorites.removeWhere((c) => c.id == carId);
    notifyListeners();

    try {
      await _favoriteService.removeFavorite(carId);
      return true;
    } catch (e) {
      // Revert on error
      _favoriteIds.add(carId);
      if (car != null) _favorites.add(car);
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear favorites (on logout)
  void clear() {
    _favorites = [];
    _favoriteIds = {};
    notifyListeners();
  }
}
