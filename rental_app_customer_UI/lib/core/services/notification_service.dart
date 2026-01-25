import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiService _api = ApiService();

  // Get all notifications
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _api.get('/notifications');
    return (response as List)
        .map((n) => NotificationModel.fromJson(n))
        .toList();
  }

  // Get unread notifications
  Future<List<NotificationModel>> getUnreadNotifications() async {
    final response = await _api.get('/notifications/unread');
    return (response as List)
        .map((n) => NotificationModel.fromJson(n))
        .toList();
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    final response = await _api.get('/notifications/unread/count');
    return response['count'] ?? 0;
  }

  // Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    await _api.put('/notifications/$notificationId/read');
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _api.put('/notifications/read-all');
  }

  // Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    await _api.delete('/notifications/$notificationId');
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    await _api.delete('/notifications/all');
  }

  // Get notifications by type
  Future<List<NotificationModel>> getNotificationsByType(NotificationType type) async {
    final response = await _api.get('/notifications/type/${type.name}');
    return (response as List)
        .map((n) => NotificationModel.fromJson(n))
        .toList();
  }
}
