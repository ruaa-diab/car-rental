import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'booking',
      'title': 'New Booking Created',
      'message': 'Ahmad Khalil booked Toyota Camry for 5 days',
      'time': '5 minutes ago',
      'isRead': false,
      'icon': Icons.event_available,
      'color': AppColors.primary,
    },
    {
      'id': '2',
      'type': 'payment',
      'title': 'Payment Received',
      'message': 'Payment of \$225 received from Sara Mohammed',
      'time': '1 hour ago',
      'isRead': false,
      'icon': Icons.payments,
      'color': AppColors.success,
    },
    {
      'id': '3',
      'type': 'car',
      'title': 'Car Maintenance Due',
      'message': 'BMW X5 (BMW-7777) requires maintenance check',
      'time': '3 hours ago',
      'isRead': true,
      'icon': Icons.build,
      'color': AppColors.warning,
    },
    {
      'id': '4',
      'type': 'customer',
      'title': 'New Customer Registration',
      'message': 'Layla Ali has registered as a new customer',
      'time': '5 hours ago',
      'isRead': true,
      'icon': Icons.person_add,
      'color': AppColors.info,
    },
    {
      'id': '5',
      'type': 'booking',
      'title': 'Booking Cancelled',
      'message': 'Yousef Ibrahim cancelled booking BK-005',
      'time': '1 day ago',
      'isRead': true,
      'icon': Icons.cancel,
      'color': AppColors.error,
    },
    {
      'id': '6',
      'type': 'employee',
      'title': 'Employee Leave Request',
      'message': 'Ahmad Yousef requested leave for Jan 20-22',
      'time': '1 day ago',
      'isRead': true,
      'icon': Icons.beach_access,
      'color': const Color(0xFF9C27B0),
    },
    {
      'id': '7',
      'type': 'car',
      'title': 'Car Returned',
      'message': 'Honda CR-V returned by Sara Mohammed',
      'time': '2 days ago',
      'isRead': true,
      'icon': Icons.assignment_return,
      'color': AppColors.success,
    },
    {
      'id': '8',
      'type': 'system',
      'title': 'System Update',
      'message': 'New version 1.0.1 is available',
      'time': '3 days ago',
      'isRead': true,
      'icon': Icons.system_update,
      'color': AppColors.textSecondary,
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'All') {
      return _notifications;
    } else if (_selectedFilter == 'Unread') {
      return _notifications.where((n) => !(n['isRead'] as bool)).toList();
    } else {
      return _notifications.where((n) => n['isRead'] as bool).toList();
    }
  }

  int get _unreadCount {
    return _notifications.where((n) => !(n['isRead'] as bool)).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),

          // Stats Bar
          _buildStatsBar(),

          // Notifications List
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardWhite,
      child: Row(
        children: [
          _buildFilterChip('All'),
          const SizedBox(width: 8),
          _buildFilterChip('Unread'),
          const SizedBox(width: 8),
          _buildFilterChip('Read'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    int count = 0;

    if (label == 'All') {
      count = _notifications.length;
    } else if (label == 'Unread') {
      count = _unreadCount;
    } else {
      count = _notifications.length - _unreadCount;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.softBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.3) : AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.cardWhite,
      child: Row(
        children: [
          Icon(Icons.notifications_active, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$_unreadCount unread notification${_unreadCount == 1 ? '' : 's'}',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = _filteredNotifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;

    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.remove(notification);
        });
        _showSnackBar('Notification deleted');
      },
      child: InkWell(
        onTap: () {
          _markAsRead(notification);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? AppColors.cardWhite : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead ? Colors.transparent : AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (notification['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: notification['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isRead ? AppColors.textPrimary : AppColors.primary,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification['message'],
                      style: AppTextStyles.caption.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          notification['time'],
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'Unread'
                ? 'All caught up! No unread notifications.'
                : 'You have no notifications at the moment',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _markAsRead(Map<String, dynamic> notification) {
    setState(() {
      notification['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    _showSnackBar('All notifications marked as read');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}