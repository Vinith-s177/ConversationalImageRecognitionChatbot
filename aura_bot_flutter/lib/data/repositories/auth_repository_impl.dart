import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aura_bot_flutter/data/models/user_model.dart';
import 'package:aura_bot_flutter/domain/entities/user_entity.dart';
import 'package:aura_bot_flutter/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  String get _baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8081';
  }

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    // For our demo, the backend login takes 'username', so we pass email as username if needed,
    // or we assume user enters username instead of email. The UI might say email. 
    // Wait, the backend login takes username. Let's pass the email as username for now
    // or let the backend handle it.
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json', 'Bypass-Tunnel-Reminder': 'true'},
        body: jsonEncode({'username': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = data['user'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        return UserModel(
          id: user['id'].toString(),
          fullName: user['fullName'],
          email: user['email'],
          mobileNumber: user['mobileNumber'],
          username: user['username'],
        );
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception(error ?? 'Authentication failed.');
      }
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  @override
  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json', 'Bypass-Tunnel-Reminder': 'true'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'mobileNumber': mobileNumber,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = data['user'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        return UserModel(
          id: user['id'].toString(),
          fullName: user['fullName'],
          email: user['email'],
          mobileNumber: user['mobileNumber'],
          username: user['username'],
        );
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception(error ?? 'Registration failed.');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/me'),
        headers: {'Authorization': 'Bearer $token', 'Bypass-Tunnel-Reminder': 'true'},
      );

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        return UserModel(
          id: user['id'].toString(),
          fullName: user['fullName'],
          email: user['email'],
          mobileNumber: user['mobileNumber'],
          username: user['username'],
        );
      }
    } catch (e) {
      // Token might be invalid or expired
      await prefs.remove('auth_token');
    }
    return null;
  }

  @override
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json', 'Bypass-Tunnel-Reminder': 'true'},
        body: json.encode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json', 'Bypass-Tunnel-Reminder': 'true'},
        body: json.encode({'email': email, 'otp': otp}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json', 'Bypass-Tunnel-Reminder': 'true'},
        body: json.encode({'email': email, 'otp': otp, 'newPassword': newPassword}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
