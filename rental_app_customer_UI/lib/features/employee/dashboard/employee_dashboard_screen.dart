import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/employee_header.dart';
import '../../../core/widgets/employee_bottom_nav.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/employee_service.dart';
import '../../../core/services/task_service.dart';
import '../tasks/tasks_list_screen.dart';
import '../performance/performance_screen.dart';
import '../../shared/rent_car_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  bool _isLoading = true;
  String _employeeName = "";
  int _employeeId = 0;
  int _tasksToday = 0;
  int _completedToday = 0;
  int _pendingTasks = 0;
  int _inProgressTasks = 0;
  List<Map<String, dynamic>> _upcomingTasks = [];

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId != null) {
        // Get employee data
        try {
          final employeeData = await EmployeeService.instance.getEmployeeByUserId(userId);
          _employeeId = employeeData['id'] ?? 0;
          _employeeName = employeeData['fullName']?.toString().split(' ').first ?? 'Employee';
        } catch (e) {
          _employeeName = authProvider.user?.fullName.split(' ').first ?? 'Employee';
        }

        // Get tasks for employee
        if (_employeeId > 0) {
          try {
            final tasksResponse = await TaskService.instance.getTodaysTasksForEmployee(_employeeId);
            final tasks = tasksResponse is List ? tasksResponse : [];

            _tasksToday = tasks.length;
            _completedToday = tasks.where((t) => t['status'] == 'COMPLETED').length;
            _pendingTasks = tasks.where((t) => t['status'] == 'PENDING').length;
            _inProgressTasks = tasks.where((t) => t['status'] == 'IN_PROGRESS').length;

            // Get upcoming tasks (pending or in progress)
            _upcomingTasks = tasks
                .where((t) => t['status'] == 'PENDING' || t['status'] == 'IN_PROGRESS')
                .take(3)
                .map<Map<String, dynamic>>((t) => {
                      'id': t['id'],
                      'type': t['type'] ?? 'TASK',
                      'title': t['title'] ?? 'Task',
                      'description': t['description'] ?? '',
                      'time': t['scheduledTime'] ?? '09:00 AM',
                      'date': t['scheduledDate'] ?? '',
                      'status': t['status'] ?? 'PENDING',
                      'priority': t['priority'] ?? 'NORMAL',
                    })
                .toList();
          } catch (e) {
            // Tasks API might fail, use defaults
            _tasksToday = 0;
            _completedToday = 0;
            _pendingTasks = 0;
            _inProgressTasks = 0;
            _upcomingTasks = [];
          }
        }

        if (mounted) {
          setState(() => _isLoading = false);
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            EmployeeHeader(employeeName: _employeeName.isEmpty ? 'Employee' : _employeeName),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Welcome Card
                      _buildWelcomeCard(),
                      const SizedBox(height: 24),

                      // Stats Overview
                      _buildSectionTitle('Today\'s Overview'),
                      const SizedBox(height: 12),
                      _buildStatsGrid(),
                      const SizedBox(height: 24),

                      // Upcoming Tasks
                      _buildSectionTitle('Upcoming Tasks'),
                      const SizedBox(height: 12),
                      _buildUpcomingTasks(),
                      const SizedBox(height: 24),

                      // Quick Actions
                      _buildSectionTitle('Quick Actions'),
                      const SizedBox(height: 12),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation - نفس صاحبتك
      bottomNavigationBar: const EmployeeBottomNav(currentIndex: 0),
    );
  }

  // ==================== WELCOME CARD ====================
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back! 👋',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _employeeName.isEmpty ? 'Employee' : _employeeName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCurrentDate(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STATS GRID ====================
  Widget _buildStatsGrid() {
    return GridLayout(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Total Tasks',
          _tasksToday.toString(),
          Icons.assignment,
          AppColors.primary,
        ),
        _buildStatCard(
          'In Progress',
          _inProgressTasks.toString(),
          Icons.pending_actions,
          AppColors.info,
        ),
        _buildStatCard(
          'Pending',
          _pendingTasks.toString(),
          Icons.schedule,
          AppColors.warning,
        ),
        _buildStatCard(
          'Completed',
          _completedToday.toString(),
          Icons.check_circle,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),

          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ==================== UPCOMING TASKS ====================
  Widget _buildUpcomingTasks() {
    if (_upcomingTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.task_alt,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No upcoming tasks',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All caught up! Check back later.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      );
    }

    return Column(
      children: _upcomingTasks.map((task) => _buildTaskCard(task)).toList(),
    );
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
      case 'DELIVERY':
        return Icons.local_shipping;
      default:
        return Icons.assignment;
    }
  }

  Color _getTaskColor(String type) {
    switch (type.toUpperCase()) {
      case 'SHIFT':
        return AppColors.primary;
      case 'MAINTENANCE':
        return AppColors.warning;
      case 'CLEANING':
        return AppColors.info;
      case 'INSPECTION':
        return const Color(0xFF9C27B0);
      case 'DELIVERY':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final String taskType = task['type']?.toString() ?? 'TASK';
    final Color mainColor = _getTaskColor(taskType);
    final bool isHighPriority = task['priority']?.toString().toUpperCase() == 'HIGH';
    final String status = task['status']?.toString() ?? 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: isHighPriority
            ? Border.all(color: AppColors.warning, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          if (isHighPriority)
            BoxShadow(
              color: AppColors.warning.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTaskDetailDialog(task),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Row
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTaskIcon(taskType),
                        color: mainColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Type & Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: mainColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  taskType.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isHighPriority)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.warning,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text(
                                    'URGENT',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: status == 'IN_PROGRESS'
                                      ? AppColors.info.withOpacity(0.1)
                                      : AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  status == 'IN_PROGRESS' ? 'In Progress' : 'Pending',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: status == 'IN_PROGRESS'
                                        ? AppColors.info
                                        : AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task['title']?.toString() ?? 'Task',
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),

                if (task['description'] != null && task['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 12),

                  // Description
                  Row(
                    children: [
                      const Icon(
                        Icons.notes,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task['description'].toString(),
                          style: AppTextStyles.caption.copyWith(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Time Info
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Scheduled: ${task['time'] ?? 'Not set'}',
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                    ),
                    if (task['date'] != null && task['date'].toString().isNotEmpty) ...[
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task['date'].toString(),
                        style: AppTextStyles.caption.copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDetailDialog(Map<String, dynamic> task) {
    final String taskType = task['type']?.toString() ?? 'TASK';
    final Color mainColor = _getTaskColor(taskType);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getTaskIcon(taskType), color: mainColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task['title']?.toString() ?? 'Task Details',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', taskType, mainColor),
              _buildDetailRow('Status', task['status']?.toString() ?? 'PENDING', null),
              _buildDetailRow('Priority', task['priority']?.toString() ?? 'NORMAL', null),
              if (task['description'] != null)
                _buildDetailRow('Description', task['description'].toString(), null),
              if (task['time'] != null)
                _buildDetailRow('Scheduled Time', task['time'].toString(), null),
              if (task['date'] != null)
                _buildDetailRow('Scheduled Date', task['date'].toString(), null),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (task['status'] != 'COMPLETED')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar('Task status updated');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.white,
              ),
              child: Text(task['status'] == 'PENDING' ? 'Start Task' : 'Complete Task'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color? color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: color ?? AppColors.textPrimary,
                fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionButton(
          'View All Tasks',
          'See complete list of today\'s tasks',
          Icons.list_alt,
          AppColors.primary,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TasksListScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'My Performance',
          'View your stats and achievements',
          Icons.analytics_outlined,
          AppColors.accent,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PerformanceScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'Rent a Car',
          'Book a car for yourself',
          Icons.directions_car,
          AppColors.success,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RentCarScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== SECTION TITLE ====================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
    );
  }

  // ==================== HELPERS ====================
  String _getCurrentDate() {
    final now = DateTime.now();
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Future<void> _refreshData() async {
    await _loadEmployeeData();
    _showSnackBar('Data refreshed');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

// ==================== GRID LAYOUT HELPER ====================
class GridLayout extends StatelessWidget {
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final List<Widget> children;

  const GridLayout({
    Key? key,
    required this.crossAxisCount,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < children.length; i += crossAxisCount)
          Padding(
            padding: EdgeInsets.only(
              bottom: i + crossAxisCount < children.length ? mainAxisSpacing : 0,
            ),
            child: Row(
              children: [
                for (int j = 0; j < crossAxisCount && i + j < children.length; j++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: j < crossAxisCount - 1 ? crossAxisSpacing : 0,
                      ),
                      child: children[i + j],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}