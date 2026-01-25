import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  // Change this to your backend URL
  // For Android emulator use: http://10.0.2.2:9090/api/v1
  // For iOS simulator use: http://localhost:9090/api/v1
  // For physical device use your computer's IP: http://192.168.x.x:9090/api/v1
  static const String baseUrl = 'http://localhost:9090/api/v1';

  static ApiService? _instance;
  String? _token;

  ApiService._();

  factory ApiService() {
    _instance ??= ApiService._();
    return _instance!;
  }

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? prefs.getString('auth_token');
  }

  void clearToken() {
    _token = null;
  }

  Future<Map<String, String>> _getHeaders() async {
    // Always try to load token if not set
    if (_token == null || _token!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token') ?? prefs.getString('auth_token');
    }
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw ApiException('Session expired. Please login again.',
          statusCode: 401);
    } else if (response.statusCode == 403) {
      throw ApiException('Access denied.', statusCode: 403);
    } else if (response.statusCode == 404) {
      throw ApiException('Resource not found.', statusCode: 404);
    } else {
      String message = 'Request failed';
      try {
        final body = jsonDecode(response.body);
        message = body['message'] ?? body['error'] ?? message;
      } catch (_) {}
      throw ApiException(message, statusCode: response.statusCode);
    }
  }
}
