import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/admin_header.dart';
import '../../../core/widgets/admin_bottom_nav.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/report_service.dart';
import '../cars/cars_list_screen.dart';
import '../employees/employees_list_screen.dart';
import '../customers/customers_list_screen.dart';
import '../bookings/bookings_list_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../../shared/rent_car_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _dashboardStats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await ReportService.instance.getDashboardStats();
      if (mounted) {
        setState(() {
          _dashboardStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatRevenue(dynamic value) {
    if (value == null) return '\$0';
    final num = (value is int)
        ? value.toDouble()
        : (value is double)
            ? value
            : 0.0;
    if (num >= 1000) {
      return '\$${(num / 1000).toStringAsFixed(1)}K';
    }
    return '\$${num.toStringAsFixed(0)}';
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
                final adminName =
                    authProvider.user?.fullName.split(' ').first ?? 'Manager';
                return AdminHeader(adminName: adminName);
              },
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
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
                            _buildSectionTitle('Overview'),
                            const SizedBox(height: 12),
                            _buildStatsGrid(),
                            const SizedBox(height: 24),

                            // Quick Actions
                            _buildSectionTitle('Quick Actions'),
                            const SizedBox(height: 12),
                            _buildQuickActions(),
                            const SizedBox(height: 24),

                            // Recent Activity
                            _buildSectionTitle('Recent Activity'),
                            const SizedBox(height: 12),
                            _buildRecentActivity(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }

  // ==================== WELCOME CARD ====================
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background gradient
            Container(
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
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Text(
                        authProvider.user?.fullName ?? 'Manager',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Icon decoration
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.analytics_outlined,
                    size: 80,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STATS GRID ====================
  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          title: 'Total Cars',
          value: '${_dashboardStats['totalCars'] ?? 0}',
          icon: Icons.directions_car_outlined,
          color: AppColors.primary,
          subtitle: '${_dashboardStats['activeBookings'] ?? 0} rented',
        ),
        _buildStatCard(
          title: 'Active Bookings',
          value: '${_dashboardStats['activeBookings'] ?? 0}',
          icon: Icons.event_available,
          color: AppColors.success,
          subtitle: '${_dashboardStats['upcomingBookings'] ?? 0} upcoming',
        ),
        _buildStatCard(
          title: 'Employees',
          value: '${_dashboardStats['totalEmployees'] ?? 0}',
          icon: Icons.people_outline,
          color: AppColors.info,
          subtitle: '${_dashboardStats['activeEmployees'] ?? 0} active',
        ),
        _buildStatCard(
          title: 'Monthly Revenue',
          value: _formatRevenue(_dashboardStats['monthlyRevenue']),
          icon: Icons.attach_money,
          color: AppColors.warning,
          subtitle: '${_dashboardStats['completedBookings'] ?? 0} completed',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        _buildActionCard(
          title: 'Cars',
          icon: Icons.directions_car,
          color: AppColors.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CarsListScreen()),
            );
          },
        ),
        _buildActionCard(
          title: 'Bookings',
          icon: Icons.event_note,
          color: AppColors.warning,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BookingsListScreen()),
            );
          },
        ),
        _buildActionCard(
          title: 'Reports',
          icon: Icons.assessment,
          color: const Color(0xFF9C27B0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReportsScreen()),
            );
          },
        ),
        _buildActionCard(
          title: 'Employees',
          icon: Icons.people,
          color: AppColors.info,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmployeesListScreen()),
            );
          },
        ),
        _buildActionCard(
          title: 'Customers',
          icon: Icons.person,
          color: AppColors.success,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomersListScreen()),
            );
          },
        ),
        _buildActionCard(
          title: 'Settings',
          icon: Icons.settings,
          color: AppColors.textSecondary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== RECENT ACTIVITY ====================
  Widget _buildRecentActivity() {
    final activities = [
      {
        'icon': Icons.add_circle_outline,
        'title': 'New car added',
        'subtitle': 'Toyota Camry 2024',
        'time': '2 hours ago',
        'color': AppColors.success,
      },
      {
        'icon': Icons.event_available,
        'title': 'New booking',
        'subtitle': 'Customer: Ahmad Khalil',
        'time': '4 hours ago',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.person_add,
        'title': 'New employee',
        'subtitle': 'Mohammed Hassan',
        'time': '1 day ago',
        'color': AppColors.info,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: AppColors.divider,
          indent: 72,
        ),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (activity['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: activity['color'] as Color,
                size: 24,
              ),
            ),
            title: Text(
              activity['title'] as String,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                activity['subtitle'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            trailing: Text(
              activity['time'] as String,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== HELPERS ====================
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
}
