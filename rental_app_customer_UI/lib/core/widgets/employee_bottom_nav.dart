import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/employee/dashboard/employee_dashboard_screen.dart';
import '../../features/employee/tasks/tasks_list_screen.dart';
import '../../features/employee/profile/profile_screen.dart';
import '../../features/employee/performance/performance_screen.dart';
import '../../features/employee/bookings/booking_history_screen.dart';

class EmployeeBottomNav extends StatelessWidget {
  final int currentIndex;

  const EmployeeBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget? destination;
    
    switch (index) {
      case 0: // Home
        destination = const EmployeeDashboardScreen();
        break;
      case 1: // Tasks
        destination = const TasksListScreen();
        break;
      case 2: // Performance
        destination = const PerformanceScreen();
        break;
      case 3: // Bookings
        destination = const BookingHistoryScreen();
        break;
      case 4: // Profile
        destination = const ProfileScreen();
        break;
    }

    if (destination == null) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination!,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      padding: const EdgeInsets.all(16),
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context: context,
            icon: Icons.home_outlined,
            label: 'Home',
            index: 0,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.assignment_outlined,
            label: 'Tasks',
            index: 1,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.analytics_outlined,
            label: 'Stats',
            index: 2,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.history,
            label: 'Bookings',
            index: 3,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.person_outline,
            label: 'Profile',
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: isActive
            ? const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              )
            : const BoxDecoration(),
        child: Icon(
          icon,
          size: 24,
          color: isActive ? AppColors.primary : AppColors.textOnDark,
        ),
      ),
    );
  }
}