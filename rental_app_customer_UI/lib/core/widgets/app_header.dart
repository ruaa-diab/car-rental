import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/mainApp/favorites_screen.dart';
import '../../features/mainApp/notifications_screen.dart';

class AppHeader extends StatelessWidget {
  final String greetingName;

  const AppHeader({super.key, required this.greetingName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ---------- Logo + App Name ----------
          Row(
            children: [
              Image.asset('assets/images/logo.png', width: 45, height: 45),
              const SizedBox(width: 12),
              const Text(
                'Autora',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),

          // ---------- Icons ----------
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  );
                },
                icon: const Icon(
                  Icons.favorite_border_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
