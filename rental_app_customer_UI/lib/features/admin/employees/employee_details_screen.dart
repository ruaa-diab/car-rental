import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/employee_service.dart';
import '../../../core/models/employee.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  final String employeeId;

  const EmployeeDetailsScreen({super.key, required this.employeeId});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  Employee? _employee;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  Future<void> _loadEmployee() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final id = int.parse(widget.employeeId);
      final response = await EmployeeService.instance.getEmployeeById(id);
      setState(() {
        _employee = Employee.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading employee: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.softBackground,
        appBar: AppBar(title: const Text('Employee Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _employee == null) {
      return Scaffold(
        backgroundColor: AppColors.softBackground,
        appBar: AppBar(title: const Text('Employee Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Employee not found',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadEmployee,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final employee = _employee!;
    // Map employee data for display
    final employeeData = {
      'id': employee.id.toString(),
      'name': employee.fullName,
      'email': employee.email,
      'phone': employee.phone,
      'position': employee.position,
      'department': employee.department ?? 'N/A',
      'status': employee.status.toUpperCase() == 'ACTIVE' ? 'Active' : 'Inactive',
      'joinDate': employee.hireDate != null 
          ? '${_getMonthName(employee.hireDate!.month)} ${employee.hireDate!.year}'
          : 'N/A',
      'tasksCompleted': employee.tasksCompleted ?? 0,
      'tasksInProgress': 0, // Not available in backend
      'rating': employee.rating ?? 0.0,
      'totalReviews': 0, // Not available in backend
      'onTimeRate': 0, // Not available in backend
      'avatar': employee.fullName.isNotEmpty ? employee.fullName[0].toUpperCase() : 'E',
    };

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: _buildAppBar(context, employeeData),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(employeeData),

            const SizedBox(height: 16),

            // Stats Cards
            _buildStatsCards(employeeData),

            const SizedBox(height: 16),

            // Personal Info
            _buildPersonalInfo(employeeData),

            const SizedBox(height: 16),

            // Performance
            _buildPerformance(employeeData),

            const SizedBox(height: 16),

            // Actions
            _buildActions(context, employeeData),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Map<String, dynamic> employee) {
    final isActive = employee['status'] == 'Active';

    return AppBar(
      title: Text(employee['name']),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditDialog(context),
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle_status',
              child: Text(isActive ? 'Suspend Employee' : 'Activate Employee'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete Employee'),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteDialog(context);
            } else if (value == 'toggle_status') {
              _toggleEmployeeStatus(isActive);
            }
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> employee) {
    final status = employee['status'] as String;
    final statusColor = status == 'Active' ? AppColors.success : AppColors.warning;

    return Container(
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
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Center(
                  child: Text(
                    employee['avatar'],
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            employee['name'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Position
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              employee['position'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> employee) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Tasks Done',
              employee['tasksCompleted'].toString(),
              Icons.check_circle,
              AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'In Progress',
              employee['tasksInProgress'].toString(),
              Icons.autorenew,
              AppColors.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Rating',
              employee['rating'].toString(),
              Icons.star,
              AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(Map<String, dynamic> employee) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email_outlined, 'Email', employee['email']),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_outlined, 'Phone', employee['phone']),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.business_outlined, 'Department', employee['department']),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, 'Join Date', employee['joinDate']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: AppTextStyles.caption.copyWith(fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformance(Map<String, dynamic> employee) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildPerformanceMetric(
            'On-Time Completion',
            employee['onTimeRate'],
            AppColors.success,
          ),
          const SizedBox(height: 16),
          _buildPerformanceMetric(
            'Customer Rating',
            (employee['rating'] * 20).round(),
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String title, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '$value%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, Map<String, dynamic> employee) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                _showSnackBar(context, 'View task history');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.history),
              label: const Text('Task History'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                _showSnackBar(context, 'View performance report');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.assessment),
              label: const Text('Performance Report'),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    if (_employee == null) return;

    final nameController = TextEditingController(text: _employee!.fullName);
    final phoneController = TextEditingController(text: _employee!.phone);
    final positionController = TextEditingController(text: _employee!.position);
    final departmentController = TextEditingController(text: _employee!.department ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Employee'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _updateEmployee({
                'fullName': nameController.text,
                'phone': phoneController.text,
                'position': positionController.text,
                'department': departmentController.text,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateEmployee(Map<String, dynamic> data) async {
    try {
      final id = int.parse(widget.employeeId);
      await EmployeeService.instance.updateEmployee(id, data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Employee updated successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        _loadEmployee(); // Refresh the data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update employee: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _toggleEmployeeStatus(bool isCurrentlyActive) async {
    final action = isCurrentlyActive ? 'suspend' : 'activate';
    final newStatus = isCurrentlyActive ? 'INACTIVE' : 'ACTIVE';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${isCurrentlyActive ? 'Suspend' : 'Activate'} Employee'),
        content: Text('Are you sure you want to $action this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyActive ? AppColors.warning : AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: Text(isCurrentlyActive ? 'Suspend' : 'Activate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final id = int.parse(widget.employeeId);
        await EmployeeService.instance.updateEmployee(id, {'status': newStatus});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Employee ${action}d successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          _loadEmployee(); // Refresh the data
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to $action employee: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to permanently delete this employee? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final id = int.parse(widget.employeeId);
                await EmployeeService.instance.deactivateEmployee(id);
                if (mounted) {
                  Navigator.pop(context, true); // Return true to indicate deletion
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Employee deleted successfully'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete employee: $e'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
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

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}