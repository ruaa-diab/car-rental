import 'api_service.dart';

class ReportService {
  static ReportService? _instance;
  final ApiService _api = ApiService.instance;

  ReportService._();

  static ReportService get instance {
    _instance ??= ReportService._();
    return _instance!;
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    return await _api.get('/reports/dashboard');
  }

  Future<Map<String, dynamic>> getRevenueReport(
      String startDate, String endDate) async {
    return await _api.get('/reports/revenue?startDate=$startDate&endDate=$endDate');
  }

  Future<Map<String, dynamic>> getBookingStats() async {
    return await _api.get('/reports/bookings');
  }

  Future<Map<String, dynamic>> getFleetUtilization() async {
    return await _api.get('/reports/fleet');
  }

  Future<Map<String, dynamic>> getEmployeePerformanceReport() async {
    return await _api.get('/reports/employees');
  }

  Future<Map<String, dynamic>> getEmployeePerformance(int employeeId) async {
    return await _api.get('/reports/employees/$employeeId');
  }
}
