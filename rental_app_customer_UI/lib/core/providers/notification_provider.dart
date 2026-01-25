import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnread => _unreadCount > 0;

  // Load all notifications
  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load notifications';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load unread count only (lightweight)
  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      // Ignore errors for count refresh
    }
  }

  // Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    // Find and update locally first
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      // Create updated notification (immutable update)
      final updated = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        isRead: true,
        referenceId: _notifications[index].referenceId,
        createdAt: _notifications[index].createdAt,
      );
      _notifications[index] = updated;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }

    try {
      await _notificationService.markAsRead(notificationId);
    } catch (e) {
      // Revert on error
      await loadNotifications();
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    // Update locally first
    _notifications = _notifications.map((n) => NotificationModel(
      id: n.id,
      title: n.title,
      message: n.message,
      type: n.type,
      isRead: true,
      referenceId: n.referenceId,
      createdAt: n.createdAt,
    )).toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      await _notificationService.markAllAsRead();
    } catch (e) {
      // Revert on error
      await loadNotifications();
    }
  }

  // Delete notification
  Future<void> deleteNotification(int notificationId) async {
    // Store for potential revert
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => _notifications.first,
    );
    final index = _notifications.indexWhere((n) => n.id == notificationId);

    // Remove locally first
    _notifications.removeWhere((n) => n.id == notificationId);
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();

    try {
      await _notificationService.deleteNotification(notificationId);
    } catch (e) {
      // Revert on error
      if (index != -1) {
        _notifications.insert(index, notification);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    }
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    // Store for potential revert
    final backup = List<NotificationModel>.from(_notifications);

    // Clear locally first
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();

    try {
      await _notificationService.deleteAllNotifications();
    } catch (e) {
      // Revert on error
      _notifications = backup;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear notifications (on logout)
  void clear() {
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }
}
