import 'api_service.dart';

class TaskService {
  static TaskService? _instance;
  final ApiService _api = ApiService.instance;

  TaskService._();

  static TaskService get instance {
    _instance ??= TaskService._();
    return _instance!;
  }

  Future<Map<String, dynamic>> getAllTasks({
    int page = 0,
    int size = 10,
    int? employeeId,
    String? status,
    String? type,
    String? date,
  }) async {
    String endpoint = '/tasks?page=$page&size=$size';
    if (employeeId != null) endpoint += '&employeeId=$employeeId';
    if (status != null) endpoint += '&status=$status';
    if (type != null) endpoint += '&type=$type';
    if (date != null) endpoint += '&date=$date';

    return await _api.get(endpoint);
  }

  Future<Map<String, dynamic>> getTaskById(int id) async {
    return await _api.get('/tasks/$id');
  }

  Future<List<dynamic>> getTasksByEmployeeId(int employeeId) async {
    return await _api.get('/tasks/employee/$employeeId');
  }

  Future<List<dynamic>> getTodaysTasks() async {
    return await _api.get('/tasks/today');
  }

  Future<List<dynamic>> getTodaysTasksForEmployee(int employeeId) async {
    return await _api.get('/tasks/today/employee/$employeeId');
  }

  Future<List<dynamic>> getTasksByBookingId(int bookingId) async {
    return await _api.get('/tasks/booking/$bookingId');
  }

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
    return await _api.post('/tasks', body: taskData);
  }

  Future<Map<String, dynamic>> updateTask(
      int id, Map<String, dynamic> taskData) async {
    return await _api.put('/tasks/$id', body: taskData);
  }

  Future<Map<String, dynamic>> assignEmployee(
      int taskId, int employeeId) async {
    return await _api.put('/tasks/$taskId/assign/$employeeId');
  }

  Future<Map<String, dynamic>> updateTaskStatus(int id, String status) async {
    return await _api.put('/tasks/$id/status?status=$status');
  }

  Future<void> deleteTask(int id) async {
    await _api.delete('/tasks/$id');
  }

  Future<Map<String, dynamic>> getTaskStats() async {
    return await _api.get('/tasks/stats');
  }

  Future<Map<String, dynamic>> getEmployeeTaskStats(int employeeId) async {
    return await _api.get('/tasks/stats/employee/$employeeId');
  }
}
