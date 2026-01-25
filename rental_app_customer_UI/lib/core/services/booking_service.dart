import 'api_service.dart';

class BookingService {
  static BookingService? _instance;
  final ApiService _api = ApiService.instance;

  BookingService._();

  factory BookingService() {
    _instance ??= BookingService._();
    return _instance!;
  }

  static BookingService get instance {
    _instance ??= BookingService._();
    return _instance!;
  }

  // Create a new booking (for employees/managers to rent cars)
  Future<Map<String, dynamic>> createBooking({
    required int carId,
    required int pickupBranchId,
    required int returnBranchId,
    required DateTime pickupDate,
    required DateTime returnDate,
    required String pickupTime,
    required String returnTime,
    required String cardNumber,
    required String cardExpiry,
    required String cardCvv,
    required String cardHolderName,
  }) async {
    // Detect card brand from card number
    String cardBrand = _detectCardBrand(cardNumber);

    final response = await _api.post(
      '/bookings',
      body: {
        'carId': carId,
        'pickupBranchId': pickupBranchId,
        'returnBranchId': returnBranchId,
        'pickupDate': _formatDate(pickupDate),
        'returnDate': _formatDate(returnDate),
        'pickupTime': pickupTime,
        'returnTime': returnTime,
        'cardNumber': cardNumber,
        'expiryDate': cardExpiry,
        'cvv': cardCvv,
        'cardHolderName': cardHolderName,
        'cardBrand': cardBrand,
      },
    );
    return response;
  }

  // Detect card brand from number
  String _detectCardBrand(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    if (cleanNumber.startsWith('4')) return 'VISA';
    if (cleanNumber.startsWith('5')) return 'MASTERCARD';
    if (cleanNumber.startsWith('3')) return 'AMEX';
    if (cleanNumber.startsWith('6')) return 'DISCOVER';
    return 'VISA';
  }

  // Get all user's bookings
  Future<List<dynamic>> getMyBookings() async {
    final response = await _api.get('/bookings');
    return response is List ? response : [];
  }

  // Get booking by ID
  Future<Map<String, dynamic>> getBookingById(int id) async {
    return await _api.get('/bookings/$id');
  }

  // Get bookings by status
  Future<List<dynamic>> getBookingsByStatus(String status) async {
    final response = await _api.get('/bookings/status/$status');
    return response is List ? response : [];
  }

  // Cancel a booking
  Future<Map<String, dynamic>> cancelBooking(int bookingId, {String? reason}) async {
    final response = await _api.post(
      '/bookings/$bookingId/cancel',
      body: reason != null ? {'reason': reason} : null,
    );
    return response;
  }

  // Check car availability for dates
  Future<bool> checkAvailability({
    required int carId,
    required DateTime pickupDate,
    required DateTime returnDate,
  }) async {
    final response = await _api.get(
      '/bookings/check-availability?carId=$carId&startDate=${_formatDate(pickupDate)}&endDate=${_formatDate(returnDate)}',
    );
    return response['available'] == true;
  }

  // Get booking history
  Future<List<dynamic>> getBookingHistory() async {
    final response = await _api.get('/bookings/history');
    return response is List ? response : [];
  }

  // Format date for API
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
