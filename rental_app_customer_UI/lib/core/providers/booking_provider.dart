import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/api_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<BookingModel> _bookings = [];
  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _activeBookings = [];
  List<BookingModel> _historyBookings = [];
  BookingModel? _selectedBooking;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Getters
  List<BookingModel> get bookings => _bookings;
  List<BookingModel> get upcomingBookings => _upcomingBookings;
  List<BookingModel> get activeBookings => _activeBookings;
  List<BookingModel> get historyBookings => _historyBookings;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  // Load all user bookings
  Future<void> loadAllBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _bookingService.getMyBookings();
      _bookings = response.map((json) => BookingModel.fromJson(json)).toList();
      _categorizeBookings();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load bookings';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Alias for loadAllBookings
  Future<void> loadMyBookings() => loadAllBookings();
  Future<void> loadBookings() => loadAllBookings();

  void _categorizeBookings() {
    _upcomingBookings = _bookings
        .where((b) => b.status == BookingStatus.UPCOMING)
        .toList();
    _activeBookings = _bookings
        .where((b) => b.status == BookingStatus.ACTIVE)
        .toList();
    _historyBookings = _bookings
        .where((b) =>
            b.status == BookingStatus.COMPLETED ||
            b.status == BookingStatus.CANCELLED)
        .toList();
  }

  // Load upcoming bookings
  Future<void> loadUpcomingBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _bookingService.getBookingsByStatus('UPCOMING');
      _upcomingBookings = response.map((json) => BookingModel.fromJson(json)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load upcoming bookings';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load booking history
  Future<void> loadBookingHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _bookingService.getBookingHistory();
      _historyBookings = response.map((json) => BookingModel.fromJson(json)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load booking history';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create a new booking
  Future<BookingModel?> createBooking({
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
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _bookingService.createBooking(
        carId: carId,
        pickupBranchId: pickupBranchId,
        returnBranchId: returnBranchId,
        pickupDate: pickupDate,
        returnDate: returnDate,
        pickupTime: pickupTime,
        returnTime: returnTime,
        cardNumber: cardNumber,
        cardExpiry: cardExpiry,
        cardCvv: cardCvv,
        cardHolderName: cardHolderName,
      );

      final booking = BookingModel.fromJson(response);
      _selectedBooking = booking;
      _successMessage = 'Booking confirmed! Booking #${booking.bookingNumber}';

      await loadAllBookings();

      _isLoading = false;
      notifyListeners();
      return booking;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Booking failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Cancel a booking
  Future<bool> cancelBooking(int bookingId, {String? reason}) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _bookingService.cancelBooking(bookingId, reason: reason);
      _successMessage = 'Booking cancelled successfully';

      final booking = BookingModel.fromJson(response);
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = booking;
        _categorizeBookings();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Cancellation failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check availability
  Future<bool> checkAvailability({
    required int carId,
    required DateTime pickupDate,
    required DateTime returnDate,
  }) async {
    try {
      return await _bookingService.checkAvailability(
        carId: carId,
        pickupDate: pickupDate,
        returnDate: returnDate,
      );
    } catch (e) {
      return false;
    }
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(int id) async {
    try {
      final response = await _bookingService.getBookingById(id);
      _selectedBooking = BookingModel.fromJson(response);
      notifyListeners();
      return _selectedBooking;
    } catch (e) {
      return null;
    }
  }

  // Set selected booking
  void setSelectedBooking(BookingModel booking) {
    _selectedBooking = booking;
    notifyListeners();
  }

  // Clear selected booking
  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }

  // Clear messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
