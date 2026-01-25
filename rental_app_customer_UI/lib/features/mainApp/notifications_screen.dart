import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/main_bottom_nav.dart';
import '../../core/providers/providers.dart';
import '../../core/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.loadNotifications();
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toUpperCase()) {
      case 'BOOKING_CONFIRMED':
        return Icons.check_circle;
      case 'BOOKING_CANCELLED':
        return Icons.cancel;
      case 'BOOKING_COMPLETED':
        return Icons.done_all;
      case 'BOOKING_REMINDER':
        return Icons.alarm;
      case 'NEW_CAR':
        return Icons.directions_car;
      case 'SPECIAL_OFFER':
        return Icons.local_offer;
      case 'PAYMENT_SUCCESS':
        return Icons.payment;
      case 'PAYMENT_FAILED':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toUpperCase()) {
      case 'BOOKING_CONFIRMED':
      case 'BOOKING_COMPLETED':
      case 'PAYMENT_SUCCESS':
        return Colors.green;
      case 'BOOKING_CANCELLED':
      case 'PAYMENT_FAILED':
        return Colors.red;
      case 'NEW_CAR':
      case 'SPECIAL_OFFER':
        return AppColors.primary;
      case 'BOOKING_REMINDER':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SafeArea(
        child: Column(
          children: [
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final userName = authProvider.user?.fullName.split(' ').first ?? 'User';
                return AppHeader(greetingName: userName);
              },
            ),
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  if (notificationProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (notificationProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(notificationProvider.error!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadNotifications,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (notificationProvider.notifications.isEmpty) {
                    return _emptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: notificationProvider.notifications.length,
                      itemBuilder: (context, index) {
                        return _notificationCard(notificationProvider.notifications[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationCard(NotificationModel notification) {
    final icon = _getNotificationIcon(notification.type.name);
    final color = _getNotificationColor(notification.type.name);

    return GestureDetector(
      onTap: () async {
        if (!notification.isRead) {
          final provider = Provider.of<NotificationProvider>(context, listen: false);
          await provider.markAsRead(notification.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.cardWhite : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: notification.isRead ? null : Border.all(color: AppColors.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                            color: AppColors.primaryText,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(notification.createdAt),
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'ll see your notifications here',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
