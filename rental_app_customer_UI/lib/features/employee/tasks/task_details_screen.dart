import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic>) onTaskUpdated;

  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Map<String, dynamic> task;

  @override
  void initState() {
    super.initState();
    task = Map<String, dynamic>.from(widget.task);
  }

  IconData _getTaskIcon(String type) {
    switch (type.toUpperCase()) {
      case 'SHIFT':
        return Icons.schedule;
      case 'MAINTENANCE':
        return Icons.build;
      case 'CLEANING':
        return Icons.cleaning_services;
      case 'INSPECTION':
        return Icons.search;
      default:
        return Icons.assignment;
    }
  }

  Color _getTaskColor(String type) {
    switch (type.toUpperCase()) {
      case 'SHIFT':
        return const Color(0xFF2196F3); // Blue
      case 'MAINTENANCE':
        return const Color(0xFFFF9800); // Orange
      case 'CLEANING':
        return const Color(0xFF00BCD4); // Cyan
      case 'INSPECTION':
        return const Color(0xFF9C27B0); // Purple
      default:
        return AppColors.primary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFA726); // Orange
      case 'in_progress':
        return const Color(0xFF42A5F5); // Blue
      case 'completed':
        return const Color(0xFF66BB6A); // Green
      default:
        return AppColors.textSecondary;
    }
  }

  void _updateTaskStatus(String newStatus) {
    setState(() {
      task['status'] = newStatus;
    });
    widget.onTaskUpdated(task);
  }

  @override
  Widget build(BuildContext context) {
    final String taskType = task['type'] ?? 'TASK';
    final Color mainColor = _getTaskColor(taskType);
    final bool isHighPriority = task['priority'] == 'high';
    final String status = task['status'] ?? 'pending';
    final Color statusColor = _getStatusColor(status);

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: Text(task['title'] ?? 'Task Details'),
        backgroundColor: AppColors.cardWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(mainColor, taskType, isHighPriority, status, statusColor),
            const SizedBox(height: 20),

            // Task Details
            _buildSectionTitle('Task Details'),
            const SizedBox(height: 12),
            _buildDetailsCard(mainColor),
            const SizedBox(height: 20),

            // Location
            _buildSectionTitle('Location'),
            const SizedBox(height: 12),
            _buildLocationCard(),
            const SizedBox(height: 20),

            // Notes (if any)
            if (task['notes'] != null) ...[
              _buildSectionTitle('Notes'),
              const SizedBox(height: 12),
              _buildNotesCard(),
              const SizedBox(height: 20),
            ],

            // Action Button
            _buildActionButton(mainColor, status, statusColor),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Color mainColor, String taskType, bool isHighPriority, String status, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mainColor, mainColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type & Priority Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTaskIcon(taskType),
                      size: 16,
                      color: mainColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      taskType,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isHighPriority)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.priority_high, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'URGENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Date & Time
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '${task['date']} at ${task['time']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          if (task['endTime'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  'Until ${task['endTime']}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status == 'pending'
                      ? Icons.pending_actions
                      : status == 'in_progress'
                          ? Icons.autorenew
                          : Icons.check_circle,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  status == 'pending'
                      ? 'Pending'
                      : status == 'in_progress'
                          ? 'In Progress'
                          : 'Completed',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Color mainColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            task['title'] ?? 'Task',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            task['description'] ?? 'No description provided.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          // Vehicle Plate (if applicable)
          if (task['vehiclePlate'] != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.directions_car, size: 20, color: mainColor),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task['vehiclePlate'],
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  task['location'] ?? 'Not specified',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFFF9800),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task['notes'],
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Color mainColor, String status, Color statusColor) {
    String buttonText;
    IconData buttonIcon;
    VoidCallback? onPressed;

    if (status == 'pending') {
      buttonText = 'Start Task';
      buttonIcon = Icons.play_arrow;
      onPressed = () {
        _updateTaskStatus('in_progress');
        _showSnackBar('Task started', const Color(0xFF42A5F5));
      };
    } else if (status == 'in_progress') {
      buttonText = 'Complete Task';
      buttonIcon = Icons.check;
      onPressed = () {
        _updateTaskStatus('completed');
        _showSnackBar('Task completed successfully!', const Color(0xFF66BB6A));
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context);
        });
      };
    } else {
      buttonText = 'Task Completed';
      buttonIcon = Icons.check_circle;
      onPressed = null;
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(buttonIcon, size: 24),
        label: Text(
          buttonText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: status == 'completed' ? const Color(0xFF66BB6A) : mainColor,
          disabledBackgroundColor: const Color(0xFF66BB6A).withOpacity(0.7),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: status == 'completed' ? 0 : 4,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: color,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}