import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/employee_service.dart';
import '../../../core/models/employee.dart';
import 'employee_details_screen.dart';
import 'add_employee_screen.dart';

class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({super.key});

  @override
  State<EmployeesListScreen> createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends State<EmployeesListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isLoading = true;
  List<Employee> _employees = [];
  int _currentPage = 0;
  int _totalPages = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await EmployeeService.instance.getAllEmployees(
        page: _currentPage,
        size: 10,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        status: _selectedFilter == 'All' 
            ? null 
            : (_selectedFilter == 'Active' ? 'ACTIVE' : 'INACTIVE'),
      );

      if (response['content'] != null) {
        final List<dynamic> employeesJson = response['content'];
        setState(() {
          _employees = employeesJson.map((json) => Employee.fromJson(json)).toList();
          _totalPages = response['totalPages'] ?? 0;
          _isLoading = false;
        });
      } else {
        // Handle paginated response
        final List<dynamic> employeesJson = response['content'] ?? [];
        setState(() {
          _employees = employeesJson.map((json) => Employee.fromJson(json)).toList();
          _totalPages = response['totalPages'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading employees: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  final List<Map<String, dynamic>> _dummyEmployees = [
    {
      'id': '1',
      'name': 'Khaled Ahmad',
      'email': 'khaled@autora.com',
      'phone': '+970 599 123 456',
      'position': 'Driver',
      'department': 'Operations',
      'status': 'Active',
      'joinDate': 'Jan 2024',
      'tasksCompleted': 38,
      'rating': 4.8,
      'avatar': 'K',
    },
    {
      'id': '2',
      'name': 'Sara Ali',
      'email': 'sara@autora.com',
      'phone': '+970 599 234 567',
      'position': 'Manager',
      'department': 'Management',
      'status': 'Active',
      'joinDate': 'Dec 2023',
      'tasksCompleted': 125,
      'rating': 4.9,
      'avatar': 'S',
    },
    {
      'id': '3',
      'name': 'Mohammed Hassan',
      'email': 'mohammed@autora.com',
      'phone': '+970 599 345 678',
      'position': 'Driver',
      'department': 'Operations',
      'status': 'Active',
      'joinDate': 'Feb 2024',
      'tasksCompleted': 42,
      'rating': 4.7,
      'avatar': 'M',
    },
    {
      'id': '4',
      'name': 'Fatima Khalil',
      'email': 'fatima@autora.com',
      'phone': '+970 599 456 789',
      'position': 'Support',
      'department': 'Customer Service',
      'status': 'Active',
      'joinDate': 'Mar 2024',
      'tasksCompleted': 89,
      'rating': 4.8,
      'avatar': 'F',
    },
    {
      'id': '5',
      'name': 'Ahmad Yousef',
      'email': 'ahmad@autora.com',
      'phone': '+970 599 567 890',
      'position': 'Driver',
      'department': 'Operations',
      'status': 'On Leave',
      'joinDate': 'Jan 2024',
      'tasksCompleted': 31,
      'rating': 4.6,
      'avatar': 'A',
    },
  ];

  List<Employee> get _filteredEmployees {
    if (_searchQuery.isEmpty && _selectedFilter == 'All') {
      return _employees;
    }
    
    return _employees.where((employee) {
      final matchesSearch = _searchQuery.isEmpty ||
          employee.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee.position.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'All' || 
          employee.status.toUpperCase() == _selectedFilter.toUpperCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search and Filter
          _buildSearchAndFilter(),

          // Stats Bar
          _buildStatsBar(),

          // Employees List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _filteredEmployees.isEmpty
                        ? _buildEmptyState()
                        : _buildEmployeesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEmployeeScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Add Employee',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Manage Employees'),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            _showFilterDialog();
          },
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardWhite,
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _currentPage = 0;
              });
              _loadEmployees();
            },
            decoration: InputDecoration(
              hintText: 'Search employees...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.softBackground,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Active'),
                _buildFilterChip('Inactive'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
            _currentPage = 0;
          });
          _loadEmployees();
        },
        backgroundColor: AppColors.softBackground,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    final totalEmployees = _employees.length;
    final activeEmployees = _employees.where((e) => e.status.toUpperCase() == 'ACTIVE').length;
    final inactiveEmployees = _employees.where((e) => e.status.toUpperCase() == 'INACTIVE').length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalEmployees.toString(), AppColors.primary),
          _buildStatItem('Active', activeEmployees.toString(), AppColors.success),
          _buildStatItem('Inactive', inactiveEmployees.toString(), AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildEmployeesList() {
    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredEmployees.length,
        itemBuilder: (context, index) {
          final employee = _filteredEmployees[index];
          return _buildEmployeeCard(employee);
        },
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    final status = employee.status;
    final statusColor = status.toUpperCase() == 'ACTIVE' ? AppColors.success : AppColors.warning;
    final statusText = status.toUpperCase() == 'ACTIVE' ? 'Active' : 'Inactive';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmployeeDetailsScreen(employeeId: employee.id.toString()),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  employee.fullName.isNotEmpty ? employee.fullName[0].toUpperCase() : 'E',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          employee.fullName,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee.position,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          employee.email,
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (employee.rating != null) ...[
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${employee.rating!.toStringAsFixed(1)} Rating',
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                        ),
                        const SizedBox(width: 12),
                      ],
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${employee.tasksCompleted ?? 0} Tasks',
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No employees found',
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Employees'),
              onTap: () {
                setState(() {
                  _selectedFilter = 'All';
                  _currentPage = 0;
                });
                Navigator.pop(context);
                _loadEmployees();
              },
            ),
            ListTile(
              title: const Text('Active'),
              onTap: () {
                setState(() {
                  _selectedFilter = 'Active';
                  _currentPage = 0;
                });
                Navigator.pop(context);
                _loadEmployees();
              },
            ),
            ListTile(
              title: const Text('On Leave'),
              onTap: () {
                setState(() {
                  _selectedFilter = 'On Leave';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading employees',
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadEmployees,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}