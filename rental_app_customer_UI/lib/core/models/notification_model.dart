enum NotificationType {
  BOOKING_CONFIRMED,
  BOOKING_CANCELLED,
  BOOKING_COMPLETED,
  BOOKING_REMINDER,
  NEW_CAR,
  SPECIAL_OFFER,
  PAYMENT_SUCCESS,
  PAYMENT_FAILED,
  GENERAL,
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final int? referenceId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.referenceId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: _parseType(json['type']),
      isRead: json['isRead'] ?? false,
      referenceId: json['referenceId'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'BOOKING_CONFIRMED': return NotificationType.BOOKING_CONFIRMED;
      case 'BOOKING_CANCELLED': return NotificationType.BOOKING_CANCELLED;
      case 'BOOKING_COMPLETED': return NotificationType.BOOKING_COMPLETED;
      case 'BOOKING_REMINDER': return NotificationType.BOOKING_REMINDER;
      case 'NEW_CAR': return NotificationType.NEW_CAR;
      case 'SPECIAL_OFFER': return NotificationType.SPECIAL_OFFER;
      case 'PAYMENT_SUCCESS': return NotificationType.PAYMENT_SUCCESS;
      case 'PAYMENT_FAILED': return NotificationType.PAYMENT_FAILED;
      default: return NotificationType.GENERAL;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'isRead': isRead,
      'referenceId': referenceId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper getters
  String get typeIcon {
    switch (type) {
      case NotificationType.BOOKING_CONFIRMED: return '✅';
      case NotificationType.BOOKING_CANCELLED: return '❌';
      case NotificationType.BOOKING_COMPLETED: return '🎉';
      case NotificationType.BOOKING_REMINDER: return '⏰';
      case NotificationType.NEW_CAR: return '🚗';
      case NotificationType.SPECIAL_OFFER: return '🎁';
      case NotificationType.PAYMENT_SUCCESS: return '💳';
      case NotificationType.PAYMENT_FAILED: return '⚠️';
      case NotificationType.GENERAL: return '📢';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
