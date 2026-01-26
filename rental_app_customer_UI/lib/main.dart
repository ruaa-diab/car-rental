import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'core/providers/providers.dart';
import 'core/services/auth_service.dart';
import 'core/services/api_service.dart';
import 'features/auth/splash/welcome_app_screen.dart';
import 'features/mainApp/home.dart';
import 'features/employee/dashboard/employee_dashboard_screen.dart';
import 'features/admin/dashboard/admin_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CarRentalApp());
}

class CarRentalApp extends StatelessWidget {
  const CarRentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Autora Car Rental',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.softBackground,
          fontFamily: 'SF Pro Display',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await AuthService.getToken();
    final role = await AuthService.getRole();

    // Set the token in ApiService so it's available for all requests
    if (token != null && token.isNotEmpty) {
      await ApiService().setToken(token);
    }

    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _userRole = role;
      _isLoading = false;
    });

    if (_isLoggedIn) {
      // Load user data into provider
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.loadUserFromStorage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Not logged in - show welcome/splash screen
    if (!_isLoggedIn) {
      return const WelcomeAppScreen();
    }

    // Logged in - route based on role
    return _buildRoleBasedScreen();
  }

  Widget _buildRoleBasedScreen() {
    final role = _userRole?.toUpperCase() ?? 'USER';

    switch (role) {
      case 'EMPLOYEE':
        return const EmployeeDashboardScreen();

      case 'MANAGER':
        return const AdminDashboardScreen();

      case 'USER':
      default:
        return const HomeScreen();
    }
  }
}