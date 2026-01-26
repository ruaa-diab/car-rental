import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/onboarding/onboarding_screen.dart'
    hide AppColors;

class WelcomeAppScreen extends StatefulWidget {
  const WelcomeAppScreen({super.key});

  @override
  State<WelcomeAppScreen> createState() => _WelcomeAppScreenState();
}

class _WelcomeAppScreenState extends State<WelcomeAppScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png', // YOU will adjust name
                height: 90,
              ),
              const SizedBox(height: 16),
              const Text(
                'Autora',
                style: TextStyle(
                  fontSize: 32, // BIGGER
                  fontWeight: FontWeight.bold, // BOLDER
                  color: AppColors.primaryText,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
