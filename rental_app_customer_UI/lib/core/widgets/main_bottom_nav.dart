import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/mainApp/home.dart';
import '../../features/mainApp/search_screen.dart';
import '../../features/mainApp/favorites_screen.dart';
import '../../features/mainApp/notifications_screen.dart';
import '../../features/mainApp/profile_screen.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const MainBottomNav({super.key, required this.currentIndex, this.onTap});

  void _handleNavigation(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    if (index == currentIndex) return;

    Widget? destination;
    switch (index) {
      case 0:
        destination = const HomeScreen();
        break;
      case 1:
        destination = const SearchScreen();
        break;
      case 2:
        destination = const FavoritesScreen();
        break;
      case 3:
        destination = const NotificationsScreen();
        break;
      case 4:
        destination = const ProfileScreen();
        break;
      default:
        return;
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
          _buildNavItem(context: context, icon: Icons.home_outlined, index: 0),
          _buildNavItem(context: context, icon: Icons.search_outlined, index: 1),
          _buildNavItem(context: context, icon: Icons.favorite_outline, index: 2),
          _buildNavItem(context: context, icon: Icons.notifications_outlined, index: 3),
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
