import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/mainApp/home.dart';
import '../../features/booking/booking_screen.dart';
import '../../features/mainApp/search_screen.dart';
import '../../features/mainApp/map_screen.dart';
import '../../features/mainApp/profile_screen.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const MainBottomNav({super.key, required this.currentIndex, this.onTap});

  void _handleNavigation(BuildContext context, int index) {
    // If onTap is provided, use it (for custom handling)
    if (onTap != null) {
      onTap!(index);
      return;
    }

    // Default navigation behavior
    if (index == currentIndex) return; // Already on this screen

    Widget? destination;
    switch (index) {
      case 0:
        destination = const HomeScreen();
        break;
      case 1:
        destination = const BookingScreen();
        break;
      case 2:
        destination = const SearchScreen();
        break;
      case 3:
        destination = const MapScreen();
        break;
      case 4:
        destination = const ProfileScreen();
        break;
      default:
        return;
    }

    if (destination == null) return;

    // Navigate with replacement to avoid stacking screens
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
          _buildNavItem(context: context, icon: Icons.home_outlined, index: 0),
          _buildNavItem(
            context: context,
            icon: Icons.calendar_today_outlined,
            index: 1,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.explore_outlined,
            index: 2,
          ),
          _buildNavItem(context: context, icon: Icons.map_outlined, index: 3),
          _buildNavItem(context: context, icon: Icons.person_outline, index: 4),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required int index,
  }) {
    final bool isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: isActive
            ? const BoxDecoration(color: Colors.white, shape: BoxShape.circle)
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
