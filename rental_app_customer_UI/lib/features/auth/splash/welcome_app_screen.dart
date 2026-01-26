import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding/onboarding_screen.dart';

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

    // Always go to onboarding after splash
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                'assets/images/logo.png',
                height: 90,
              ),
              const SizedBox(height: 16),
              const Text(
                'Autora',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
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