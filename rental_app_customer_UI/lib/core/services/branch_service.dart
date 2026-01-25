import 'api_service.dart';

class BranchService {
  static BranchService? _instance;
  final ApiService _api = ApiService.instance;

  BranchService._();

  factory BranchService() {
    _instance ??= BranchService._();
    return _instance!;
  }

  static BranchService get instance {
    _instance ??= BranchService._();
    return _instance!;
  }

  // Get all branches
  Future<List<dynamic>> getAllBranches() async {
    final response = await _api.get('/branches/public');
    return response is List ? response : [];
  }

  // Get active branches only
  Future<List<dynamic>> getActiveBranches() async {
    final response = await _api.get('/branches/public/active');
    return response is List ? response : [];
  }

  // Get branch by ID
  Future<Map<String, dynamic>> getBranchById(int id) async {
    return await _api.get('/branches/public/$id');
  }
}
