import 'api_service.dart';

class EmployeeService {
  static EmployeeService? _instance;
  final ApiService _api = ApiService.instance;

  EmployeeService._();

  static EmployeeService get instance {
    _instance ??= EmployeeService._();
    return _instance!;
  }

  Future<Map<String, dynamic>> getAllEmployees({
    int page = 0,
    int size = 10,
    String? search,
    String? status,
  }) async {
    String endpoint = '/employees?page=$page&size=$size';
    if (search != null && search.isNotEmpty) endpoint += '&search=$search';
    if (status != null) endpoint += '&status=$status';

    return await _api.get(endpoint);
  }

  Future<Map<String, dynamic>> getEmployeeById(int id) async {
    return await _api.get('/employees/$id');
  }

  Future<Map<String, dynamic>> getEmployeeByUserId(int userId) async {
    return await _api.get('/employees/user/$userId');
  }

  Future<Map<String, dynamic>> createEmployee(
      Map<String, dynamic> employeeData) async {
    return await _api.post('/employees', body: employeeData);
  }

  Future<Map<String, dynamic>> updateEmployee(
      int id, Map<String, dynamic> employeeData) async {
    return await _api.put('/employees/$id', body: employeeData);
  }

  Future<void> deactivateEmployee(int id) async {
    await _api.delete('/employees/$id');
  }

  Future<Map<String, dynamic>> getEmployeeStats() async {
    return await _api.get('/employees/stats');
  }

  Future<void> updateEmployeeRating(int id, double rating) async {
    await _api.put('/employees/$id/rating?rating=$rating');
  }
}
