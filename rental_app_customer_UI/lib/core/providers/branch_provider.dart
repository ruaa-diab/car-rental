import 'package:flutter/foundation.dart';
import '../models/branch_model.dart';
import '../services/branch_service.dart';
import '../services/api_service.dart';

class BranchProvider extends ChangeNotifier {
  final BranchService _branchService = BranchService();

  List<BranchModel> _branches = [];
  List<String> _cities = [];
  BranchModel? _selectedPickupBranch;
  BranchModel? _selectedReturnBranch;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BranchModel> get branches => _branches;
  List<BranchModel> get activeBranches => _branches.where((b) => b.isActive).toList();
  List<String> get cities => _cities;
  BranchModel? get selectedPickupBranch => _selectedPickupBranch;
  BranchModel? get selectedReturnBranch => _selectedReturnBranch;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all branches
  Future<void> loadBranches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _branchService.getActiveBranches();
      _branches = response.map((json) => BranchModel.fromJson(json)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load branches';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load cities
  Future<void> loadCities() async {
    try {
      // Extract unique cities from branches
      _cities = _branches.map((b) => b.city).toSet().toList();
      notifyListeners();
    } catch (e) {
      // Ignore city loading errors
    }
  }

  // Get branch by ID
  Future<BranchModel?> getBranchById(int id) async {
    try {
      final response = await _branchService.getBranchById(id);
      return BranchModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get branches by city
  List<BranchModel> getBranchesByCity(String city) {
    return _branches.where((b) => b.city == city).toList();
  }

  // Search branches
  List<BranchModel> searchBranches(String query) {
    final lowerQuery = query.toLowerCase();
    return _branches.where((b) =>
        b.name.toLowerCase().contains(lowerQuery) ||
        b.city.toLowerCase().contains(lowerQuery) ||
        b.address.toLowerCase().contains(lowerQuery)).toList();
  }

  // Set pickup branch
  void setPickupBranch(BranchModel branch) {
    _selectedPickupBranch = branch;
    _selectedReturnBranch ??= branch;
    notifyListeners();
  }

  // Set return branch
  void setReturnBranch(BranchModel branch) {
    _selectedReturnBranch = branch;
    notifyListeners();
  }

  // Clear selected branches
  void clearSelectedBranches() {
    _selectedPickupBranch = null;
    _selectedReturnBranch = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
