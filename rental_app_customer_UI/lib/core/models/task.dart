import 'booking_model.dart';
import 'employee.dart';

enum TaskType { PICKUP, RETURN }
enum TaskStatus { PENDING, IN_PROGRESS, COMPLETED }
enum TaskPriority { HIGH, NORMAL, LOW }

class TaskModel {
  final int? id;
  final String? type;
  final String? status;
  final String? priority;
  final int? employeeId;
  final int? bookingId;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final DateTime? completedAt;
  final String? notes;
  final String? location;
  final String? locationType;
  final double? latitude;
  final double? longitude;
  final String? customerName;
  final String? customerPhone;
  final String? carInfo;
  final BookingModel? booking;
  final Employee? employee;

  TaskModel({
    this.id,
    this.type,
    this.status,
    this.priority,
    this.employeeId,
    this.bookingId,
    this.scheduledDate,
    this.scheduledTime,
    this.completedAt,
    this.notes,
    this.location,
    this.locationType,
    this.latitude,
    this.longitude,
    this.customerName,
    this.customerPhone,
    this.carInfo,
    this.booking,
    this.employee,
  });

  bool get isPending => status == 'PENDING';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
  bool get isPickup => type == 'PICKUP';
  bool get isReturn => type == 'RETURN';
  bool get isHighPriority => priority == 'HIGH';

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      type: json['type'],
      status: json['status'],
      priority: json['priority'],
      employeeId: json['employeeId'],
      bookingId: json['bookingId'],
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      scheduledTime: json['scheduledTime'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
      location: json['location'],
      locationType: json['locationType'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      carInfo: json['carInfo'],
      booking: json['booking'] != null
          ? BookingModel.fromJson(json['booking'])
          : null,
      employee: json['employee'] != null
          ? Employee.fromJson(json['employee'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'priority': priority,
      'employeeId': employeeId,
      'bookingId': bookingId,
      'scheduledDate': scheduledDate?.toIso8601String().split('T')[0],
      'scheduledTime': scheduledTime,
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
      'location': location,
      'locationType': locationType,
      'latitude': latitude,
      'longitude': longitude,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'carInfo': carInfo,
    };
  }
}
