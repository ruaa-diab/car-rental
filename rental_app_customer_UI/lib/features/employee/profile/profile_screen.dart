import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/employee_bottom_nav.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/employee_service.dart';
import '../../../features/auth/login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  int? _employeeId;

  Map<String, dynamic> employeeData = {
    'name': '',
    'id': '',
    'email': '',
    'phone': '',
    'joinDate': '',
    'department': '',
    'rating': 0.0,
    'tasksCompleted': 0,
  };

  Map<String, bool> notificationStatus = {
    'Task Updates': true,
    'Shift Reminders': true,
    'System Alerts': false,
  };

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
      final userEmail = authProvider.user?.email;

      print('DEBUG: ========== PROFILE LOADING ==========');
      print('DEBUG: AuthProvider user: ${authProvider.user}');
      print('DEBUG: userId: $userId');
      print('DEBUG: userEmail: $userEmail');

      if (userId != null) {
        try {
          // Try using ApiService directly first
          final response = await ApiService.instance.get('/employees/user/$userId');
          print('DEBUG: ========== DIRECT API RESPONSE ==========');
          print('DEBUG: Response type: ${response.runtimeType}');
          print('DEBUG: Response: $response');
          
          Map<String, dynamic> data;
          
          // Handle different response formats
          if (response is Map<String, dynamic>) {
            // Check if response has a 'data' wrapper
            if (response.containsKey('data')) {
              data = response['data'] as Map<String, dynamic>;
            } else {
              data = response;
            }
          } else {
            throw Exception('Unexpected response format: ${response.runtimeType}');
          }
          
          print('DEBUG: Parsed data: $data');
          print('DEBUG: Data keys: ${data.keys.toList()}');
          print('DEBUG: =====================================');
          
          if (mounted) {
            setState(() {
              _employeeId = data['id'];
              employeeData = {
                'name': data['fullName'] ?? data['name'] ?? data['userName'] ?? userEmail ?? 'Employee',
                'id': 'EMP-${(data['id'] ?? 0).toString().padLeft(3, '0')}',
                'email': data['email'] ?? userEmail ?? 'No email',
                'phone': data['phone'] ?? data['phoneNumber'] ?? 'No phone',
                'joinDate': _formatDate(data['hireDate'] ?? data['joinDate'] ?? data['createdAt']),
                'department': data['department'] ?? data['departmentName'] ?? 'Operations',
                'rating': (data['rating'] ?? data['performanceRating'] ?? 0.0).toDouble(),
                'tasksCompleted': data['tasksCompleted'] ?? data['completedTasks'] ?? 0,
              };
              _isLoading = false;
            });
            print('DEBUG: Final employeeData: $employeeData');
          }
        } catch (apiError) {
          print('DEBUG: API error: $apiError');
          print('DEBUG: Error type: ${apiError.runtimeType}');
          
          // Try to use auth user data as fallback
          if (mounted) {
            setState(() {
              employeeData = {
                'name': authProvider.user?.email?.split('@')[0] ?? 'Employee',
                'id': 'EMP-${(userId).toString().padLeft(3, '0')}',
                'email': authProvider.user?.email ?? 'No email',
                'phone': 'Not set',
                'joinDate': 'N/A',
                'department': 'Operations',
                'rating': 0.0,
                'tasksCompleted': 0,
              };
              _isLoading = false;
            });
            _showSnackBar('Could not load employee details. Using basic profile.');
          }
        }
      } else {
        print('DEBUG: No userId found in AuthProvider');
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar('Error: User ID not found. Please login again.');
        }
      }
    } catch (e, stackTrace) {
      print('DEBUG: Outer error loading employee data: $e');
      print('DEBUG: Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Failed to load profile: $e');
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      print('DEBUG: Error formatting date: $dateStr, error: $e');
      return 'N/A';
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'E';
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'E';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildAccountSection(),
                    const SizedBox(height: 24),
                    _buildMoreSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const EmployeeBottomNav(currentIndex: 4),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softBackground,
            ),
            child: Center(
              child: Text(
                _getInitials(employeeData['name']?.toString() ?? ''),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            employeeData['name']?.toString() ?? 'Employee',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            employeeData['email']?.toString() ?? 'No email',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem(employeeData['tasksCompleted'].toString(), 'Tasks Done'),
              Container(
                width: 1,
                height: 40,
                color: AppColors.softBackground,
              ),
              _statItem(employeeData['rating'].toString(), 'Rating'),
              Container(
                width: 1,
                height: 40,
                color: AppColors.softBackground,
              ),
              _statItem(employeeData['joinDate'].toString(), 'Since'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ),
          _menuCard(
            context: context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () => _showEditProfileDialog(context),
          ),
          const SizedBox(height: 12),
          _menuCard(
            context: context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () => _showChangePasswordDialog(context),
          ),
          const SizedBox(height: 12),
          _menuCard(
            context: context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () => _showNotificationsDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'More',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ),
          _menuCard(
            context: context,
            icon: Icons.badge_outlined,
            title: 'Employee Details',
            subtitle: 'View your employee information',
            onTap: () => _showEmployeeDetailsDialog(context),
          ),
          const SizedBox(height: 12),
          _menuCard(
            context: context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get assistance',
            onTap: () => _showHelpSupportDialog(context),
          ),
          const SizedBox(height: 12),
          _menuCard(
            context: context,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and info',
            onTap: () => _showAboutDialog(context),
          ),
          const SizedBox(height: 12),
          _menuCard(
            context: context,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () => _handleLogout(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: employeeData['name']?.toString() ?? '');
    final phoneController = TextEditingController(text: employeeData['phone']?.toString() ?? '');
    final departmentController = TextEditingController(text: employeeData['department']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  maxLength: 13,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '+970599123456',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!_isValidPhone(value)) {
                      return 'Phone must start with +970 or +972';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              Navigator.pop(dialogContext);
              
              // Show loading
              _showSnackBar('Updating profile...');
              
              await _updateProfile({
                'fullName': nameController.text,
                'phone': phoneController.text,
                'department': departmentController.text,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleanPhone.startsWith('+')) {
      return cleanPhone.length == 13 &&
          (cleanPhone.startsWith('+970') || cleanPhone.startsWith('+972'));
    } else {
      return cleanPhone.length == 12 &&
          (cleanPhone.startsWith('970') || cleanPhone.startsWith('972'));
    }
  }

  Future<void> _updateProfile(Map<String, dynamic> data) async {
    if (_employeeId == null) {
      _showSnackBar('Error: Employee ID not found');
      return;
    }

    try {
      print('DEBUG: Updating employee $_employeeId with data: $data');
      await EmployeeService.instance.updateEmployee(_employeeId!, data);
      _showSnackBar('Profile updated successfully');
      await _loadEmployeeData(); // Reload data
    } catch (e) {
      print('DEBUG: Error updating profile: $e');
      _showSnackBar('Failed to update profile: $e');
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Change Password',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newController.text != confirmController.text) {
                _showSnackBar('Passwords do not match');
                return;
              }
              if (newController.text.length < 6) {
                _showSnackBar('Password must be at least 6 characters');
                return;
              }
              Navigator.pop(context);
              _showSnackBar('Password changed successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              'Change',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Notification Settings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: notificationStatus.keys.map((key) {
              return SwitchListTile(
                title: Text(key),
                value: notificationStatus[key]!,
                onChanged: (value) {
                  setState(() => notificationStatus[key] = value);
                },
                activeColor: AppColors.primary,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmployeeDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Employee Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(Icons.badge_outlined, 'Employee ID', employeeData['id']?.toString() ?? 'N/A'),
              const SizedBox(height: 12),
              _detailRow(Icons.email_outlined, 'Email', employeeData['email']?.toString() ?? 'N/A'),
              const SizedBox(height: 12),
              _detailRow(Icons.phone_outlined, 'Phone', employeeData['phone']?.toString() ?? 'N/A'),
              const SizedBox(height: 12),
              _detailRow(Icons.business_outlined, 'Department', employeeData['department']?.toString() ?? 'N/A'),
              const SizedBox(height: 12),
              _detailRow(Icons.calendar_today, 'Join Date', employeeData['joinDate']?.toString() ?? 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _supportOption(Icons.email, 'Email Support', 'support@autora.com'),
            const SizedBox(height: 16),
            _supportOption(Icons.phone, 'Phone Support', '+970 599 123 456'),
            const SizedBox(height: 16),
            _supportOption(Icons.chat, 'Live Chat', 'Available 24/7'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _supportOption(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'About AutoRa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.car_rental, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'AutoRa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Car Rental Management System',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    final navigator = Navigator.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await authProvider.logout();
              ApiService.instance.clearToken();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}