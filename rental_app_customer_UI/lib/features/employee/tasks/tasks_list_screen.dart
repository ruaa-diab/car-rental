import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/employee_header.dart';
import '../../../core/widgets/employee_bottom_nav.dart';
import 'task_details_screen.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            EmployeeHeader(employeeName: 'Khaled'),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshTasks,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'All Tasks',
                            style: AppTextStyles.appTitle,
                          ),
                          // Sort Button
                          IconButton(
                            icon: Icon(
                              Icons.sort,
                              color: AppColors.primary,
                            ),
                            onPressed: _showSortOptions,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
                      _buildSearchBar(),
                      const SizedBox(height: 16),

                      // Filter Chips
                      _buildFilterChips(),
                      const SizedBox(height: 24),

                      // Tasks List
                      _buildTasksList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const EmployeeBottomNav(currentIndex: 1),
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // ==================== FILTER CHIPS ====================
  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'icon': Icons.list_alt, 'count': 8},
      {'label': 'Pending', 'icon': Icons.pending_actions, 'count': 2},
      {'label': 'In Progress', 'icon': Icons.autorenew, 'count': 3},
      {'label': 'Completed', 'icon': Icons.check_circle, 'count': 3},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['label'];
          final label = filter['label'] as String;
          final icon = filter['icon'] as IconData;
          final count = filter['count'] as int;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(label),
                  const SizedBox(width: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = label;
                });
              },
              backgroundColor: AppColors.cardWhite,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              elevation: isSelected ? 4 : 0,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== TASKS LIST ====================
  Widget _buildTasksList() {
    // Task data with proper types (SHIFT, MAINTENANCE, CLEANING, etc.)
    final tasksByDate = {
      'Today': [
        {
          'id': 1,
          'type': 'SHIFT',
          'title': 'Morning Shift',
          'time': '08:00 AM',
          'timeRemaining': 'Started',
          'description': 'Front desk duty at main branch',
          'location': 'Main Branch - Ramallah',
          'priority': 'normal',
          'status': 'in_progress',
        },
        {
          'id': 2,
          'type': 'MAINTENANCE',
          'title': 'Oil Change - Toyota Camry',
          'time': '10:00 AM',
          'timeRemaining': 'In 2 hours',
          'description': 'Regular oil change and filter replacement',
          'location': 'Workshop',
          'priority': 'high',
          'status': 'pending',
        },
        {
          'id': 3,
          'type': 'CLEANING',
          'title': 'Deep Clean - Honda CR-V',
          'time': '02:00 PM',
          'timeRemaining': 'In 6 hours',
          'description': 'Interior and exterior cleaning before rental',
          'location': 'Cleaning Bay',
          'priority': 'normal',
          'status': 'pending',
        },
      ],
      'Tomorrow': [
        {
          'id': 4,
          'type': 'INSPECTION',
          'title': 'Vehicle Inspection - BMW X5',
          'time': '09:00 AM',
          'timeRemaining': 'Tomorrow',
          'description': 'Pre-rental inspection checklist',
          'location': 'Main Branch',
          'priority': 'normal',
          'status': 'pending',
        },
        {
          'id': 5,
          'type': 'MAINTENANCE',
          'title': 'Tire Rotation - Nissan Altima',
          'time': '11:00 AM',
          'timeRemaining': 'Tomorrow',
          'description': 'Rotate tires and check pressure',
          'location': 'Workshop',
          'priority': 'high',
          'status': 'pending',
        },
        {
          'id': 6,
          'type': 'SHIFT',
          'title': 'Evening Shift',
          'time': '04:00 PM',
          'timeRemaining': 'Tomorrow',
          'description': 'Customer service and closing duties',
          'location': 'Main Branch - Ramallah',
          'priority': 'normal',
          'status': 'pending',
        },
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tasksByDate.entries.map((entry) {
        final date = entry.key;
        final tasks = entry.value;

        // Filter tasks
        final filteredTasks = tasks.where((task) {
          // Filter by status
          if (_selectedFilter != 'All') {
            final status = task['status'] as String;
            if (_selectedFilter == 'Pending' && status != 'pending') return false;
            if (_selectedFilter == 'In Progress' && status != 'in_progress')
              return false;
            if (_selectedFilter == 'Completed' && status != 'completed')
              return false;
          }

          // Filter by search
          if (_searchQuery.isNotEmpty) {
            final title = (task['title'] as String).toLowerCase();
            final description = (task['description'] as String).toLowerCase();
            final location = (task['location'] as String).toLowerCase();
            return title.contains(_searchQuery) ||
                description.contains(_searchQuery) ||
                location.contains(_searchQuery);
          }

          return true;
        }).toList();

        if (filteredTasks.isEmpty) return SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$date - ${filteredTasks.length} tasks',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Tasks
            ...filteredTasks.map((task) => _buildTaskCard(task)).toList(),

            const SizedBox(height: 24),
          ],
        );
      }).toList(),
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

  // ==================== TASK CARD ====================
  Widget _buildTaskCard(Map<String, dynamic> task) {
    final String taskType = task['type']?.toString() ?? 'TASK';
    final Color mainColor = _getTaskColor(taskType);
    final bool isHighPriority = task['priority'] == 'high';
    final String status = task['status'] as String;

    // Status badge
    Color statusColor;
    String statusText;
    switch (status) {
      case 'pending':
        statusColor = AppColors.warning;
        statusText = 'Pending';
        break;
      case 'in_progress':
        statusColor = AppColors.info;
        statusText = 'In Progress';
        break;
      case 'completed':
        statusColor = AppColors.success;
        statusText = 'Completed';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'Unknown';
    }

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
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailsScreen(taskId: task['id']),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type, Priority, Status
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
                              taskType,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
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
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Time
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task['time']} • ${task['timeRemaining']}',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Title
                      Text(
                        task['title']?.toString() ?? 'Task',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              task['location']?.toString() ?? '',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== HELPERS ====================
  Future<void> _refreshTasks() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // TODO: Refresh data from API
    });
    _showSnackBar('Tasks refreshed');
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort By',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 16),
              _buildSortOption('Time (Earliest First)', Icons.access_time),
              _buildSortOption('Time (Latest First)', Icons.access_time),
              _buildSortOption('Priority (High First)', Icons.priority_high),
              _buildSortOption('Customer Name (A-Z)', Icons.sort_by_alpha),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body),
      onTap: () {
        Navigator.pop(context);
        _showSnackBar('Sorted by: $title');
      },
    );
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