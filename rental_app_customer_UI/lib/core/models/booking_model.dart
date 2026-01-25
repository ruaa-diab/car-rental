import 'car_model.dart';
import 'user_model.dart';
import 'branch_model.dart';

enum BookingStatus { UPCOMING, ACTIVE, COMPLETED, CANCELLED }

class BookingModel {
  final int id;
  final String bookingNumber;
  final UserModel? user;
  final CarModel? car;
  final BranchModel? pickupBranch;
  final BranchModel? returnBranch;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String? pickupTime;
  final String? returnTime;
  final BookingStatus status;
  final double pricePerDay;
  final int totalDays;
  final double totalPrice;
  final PaymentModel? payment;
  final DateTime createdAt;
  final String? cancelledReason;
  final DateTime? cancelledAt;

  BookingModel({
    required this.id,
    required this.bookingNumber,
    this.user,
    this.car,
    this.pickupBranch,
    this.returnBranch,
    required this.pickupDate,
    required this.returnDate,
    this.pickupTime,
    this.returnTime,
    required this.status,
    required this.pricePerDay,
    required this.totalDays,
    required this.totalPrice,
    this.payment,
    required this.createdAt,
    this.cancelledReason,
    this.cancelledAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      bookingNumber: json['bookingNumber'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      car: json['car'] != null ? CarModel.fromJson(json['car']) : null,
      pickupBranch: json['pickupBranch'] != null 
          ? BranchModel.fromJson(json['pickupBranch']) 
          : null,
      returnBranch: json['returnBranch'] != null 
          ? BranchModel.fromJson(json['returnBranch']) 
          : null,
      pickupDate: DateTime.parse(json['pickupDate']),
      returnDate: DateTime.parse(json['returnDate']),
      pickupTime: json['pickupTime'],
      returnTime: json['returnTime'],
      status: _parseStatus(json['status']),
      pricePerDay: (json['pricePerDay'] ?? 0).toDouble(),
      totalDays: json['totalDays'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      payment: json['payment'] != null 
          ? PaymentModel.fromJson(json['payment']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      cancelledReason: json['cancelledReason'],
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt']) 
          : null,
    );
  }

  static BookingStatus _parseStatus(String? status) {
    switch (status) {
      case 'UPCOMING': return BookingStatus.UPCOMING;
      case 'ACTIVE': return BookingStatus.ACTIVE;
      case 'COMPLETED': return BookingStatus.COMPLETED;
      case 'CANCELLED': return BookingStatus.CANCELLED;
      default: return BookingStatus.UPCOMING;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingNumber': bookingNumber,
      'pickupDate': pickupDate.toIso8601String().split('T')[0],
      'returnDate': returnDate.toIso8601String().split('T')[0],
      'pickupTime': pickupTime,
      'returnTime': returnTime,
      'status': status.name,
      'pricePerDay': pricePerDay,
      'totalDays': totalDays,
      'totalPrice': totalPrice,
      'car': car?.toJson(),
      'pickupBranch': pickupBranch?.toJson(),
      'returnBranch': returnBranch?.toJson(),
    };
  }

  // Helper getters
  String get statusDisplay {
    switch (status) {
      case BookingStatus.UPCOMING: return 'Upcoming';
      case BookingStatus.ACTIVE: return 'Active';
      case BookingStatus.COMPLETED: return 'Completed';
      case BookingStatus.CANCELLED: return 'Cancelled';
    }
  }

  // Helper getters for car info (used in UI screens)
  String? get carName => car?.name;
  String? get carImageUrl => car?.imageUrl;

  bool get canCancel => status == BookingStatus.UPCOMING;
  bool get isActive => status == BookingStatus.ACTIVE;
  bool get isCompleted => status == BookingStatus.COMPLETED;
}

enum PaymentStatus { PENDING, COMPLETED, FAILED, REFUNDED }
enum PaymentMethod { VISA, MASTERCARD, AMEX, CASH }

class PaymentModel {
  final int id;
  final String transactionId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? cardLastFour;
  final String? cardBrand;
  final String? cardHolderName;
  final DateTime? paidAt;
  final DateTime? refundedAt;

  PaymentModel({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.method,
    required this.status,
    this.cardLastFour,
    this.cardBrand,
    this.cardHolderName,
    this.paidAt,
    this.refundedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      transactionId: json['transactionId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      method: _parseMethod(json['paymentMethod']),
      status: _parsePaymentStatus(json['status']),
      cardLastFour: json['cardLastFour'],
      cardBrand: json['cardBrand'],
      cardHolderName: json['cardHolderName'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      refundedAt: json['refundedAt'] != null ? DateTime.parse(json['refundedAt']) : null,
    );
  }

  static PaymentMethod _parseMethod(String? method) {
    switch (method) {
      case 'VISA': return PaymentMethod.VISA;
      case 'MASTERCARD': return PaymentMethod.MASTERCARD;
      case 'AMEX': return PaymentMethod.AMEX;
      case 'CASH': return PaymentMethod.CASH;
      default: return PaymentMethod.VISA;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
      case 'PENDING': return PaymentStatus.PENDING;
      case 'COMPLETED': return PaymentStatus.COMPLETED;
      case 'FAILED': return PaymentStatus.FAILED;
      case 'REFUNDED': return PaymentStatus.REFUNDED;
      default: return PaymentStatus.PENDING;
    }
  }

  String get maskedCard => cardLastFour != null ? '**** **** **** $cardLastFour' : '';
}
