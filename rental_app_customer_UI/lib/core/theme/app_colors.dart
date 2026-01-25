import 'package:flutter/material.dart';

class AppColors {
  // Background Colors
  static const Color background = Color(0xFFF8F9FE); // Soft light blue-white
  static const Color cardWhite = Color(0xFFFFFFFF); // Pure white for cards
  static const Color softBackground = Color(0xFFF5F6FA); // Alternative bg

  // Primary/Button Colors
  static const Color primary = Color(0xFF170142); // Vibrant blue (main CTA)
  static const Color primaryLight = Color(0xFF8B94FF); // Lighter blue variant
  static const Color actionBlue = Color(
    0xFF170142,
  ); // Same as primary (for compatibility)

  // Secondary/Accent Colors
  static const Color accent = Color(0xFFB794FF); // Purple accent
  static const Color accentPink = Color(0xFFFF8BA7); // Coral/pink accent

  // Navigation/Bottom Bar
  static const Color navigationBg = Color(0xFF2D2D44); // Dark navy/purple
  static const Color navigationActive = Color(0xFF5B68F4); // Active tab color
  static const Color navigationInactive = Color(0xFF8E8EA9); // Inactive icons

  // Text Colors
  static const Color primaryText = Color(0xFF1A1A2E); // Alias for compatibility
  static const Color textSecondary = Color(0xFF6B6B80); // Lighter text
  static const Color textLight = Color(0xFF9E9EB0); // Subtle text
  static const Color textOnDark = Color(0xFFFFFFFF); // White text on dark bg

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // UI Elements
  static const Color divider = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color ratingStar = Color(0xFFFFC107);
  static const Color price = Color(0xFF4CAF50);
  static const Color textHint = Color(0xFF9E9EB0);
}
