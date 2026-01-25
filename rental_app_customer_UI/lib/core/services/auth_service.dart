import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'dart:convert';

class AuthService {
  final ApiService _apiService = ApiService();

  // Login
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post('/auth/login', body: {
      'email': email,
      'password': password,
    });

    // Save token and user data
    final token = response['token'];
    final user = UserModel.fromJson(response);

    await saveToken(token);
    await saveRole(user.role);
    await saveUser(user);

    return user;
  }

  // Register (customers only)
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _apiService.post('/auth/register', body: {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
    });

    // Save token and user data
    final token = response['token'];
    final user = UserModel.fromJson(response);

    await saveToken(token);
    await saveRole(user.role);
    await saveUser(user);

    return user;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout', body: {});
    } catch (e) {
      // Ignore logout errors
    }

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Update profile
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    final Map<String, dynamic> body = {};
    if (fullName != null) body['fullName'] = fullName;
    if (phone != null) body['phone'] = phone;

    final response = await _apiService.put('/users/profile', body: body);
    final user = UserModel.fromJson(response);
    await saveUser(user);
    return user;
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiService.put('/users/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  // Storage methods
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveRole(String? role) async {
    if (role == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toJson()));
  }

  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
