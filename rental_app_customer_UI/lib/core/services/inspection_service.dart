import 'api_service.dart';

class InspectionService {
  static InspectionService? _instance;
  final ApiService _api = ApiService.instance;

  InspectionService._();

  static InspectionService get instance {
    _instance ??= InspectionService._();
    return _instance!;
  }

  Future<Map<String, dynamic>> getAllInspections({
    int page = 0,
    int size = 10,
  }) async {
    return await _api.get('/inspections?page=$page&size=$size');
  }

  Future<Map<String, dynamic>> getInspectionById(int id) async {
    return await _api.get('/inspections/$id');
  }

  Future<List<dynamic>> getInspectionsByTaskId(int taskId) async {
    return await _api.get('/inspections/task/$taskId');
  }

  Future<Map<String, dynamic>> getInspectionByTaskIdAndType(
      int taskId, String type) async {
    return await _api.get('/inspections/task/$taskId/type/$type');
  }

  Future<List<dynamic>> getInspectionsByBookingId(int bookingId) async {
    return await _api.get('/inspections/booking/$bookingId');
  }

  Future<List<dynamic>> getInspectionsByCarId(int carId) async {
    return await _api.get('/inspections/car/$carId');
  }

  Future<Map<String, dynamic>> createInspection(
      Map<String, dynamic> inspectionData) async {
    return await _api.post('/inspections', body: inspectionData);
  }

  Future<Map<String, dynamic>> updateInspection(
      int id, Map<String, dynamic> inspectionData) async {
    return await _api.put('/inspections/$id', body: inspectionData);
  }

  Future<Map<String, dynamic>> addPhotos(int id, List<String> photoUrls) async {
    return await _api.post('/inspections/$id/photos', body: {'urls': photoUrls});
  }

  Future<Map<String, dynamic>> setSignature(int id, String signatureUrl) async {
    return await _api
        .post('/inspections/$id/signature', body: {'signatureUrl': signatureUrl});
  }

  Future<void> deleteInspection(int id) async {
    await _api.delete('/inspections/$id');
  }

  Future<Map<String, dynamic>> getInspectionStats() async {
    return await _api.get('/inspections/stats');
  }
}
