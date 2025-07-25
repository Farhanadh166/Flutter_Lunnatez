import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_response.dart';
import 'register_response.dart';
import '../../../core/constants.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class AuthService {
  
  // Menyimpan token ke SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Mengambil token dari SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Menghapus token dari SharedPreferences (logout)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // Auto-refresh token jika expired
  static Future<String?> refreshTokenIfNeeded() async {
    try {
      debugPrint('AuthService.refreshTokenIfNeeded - Starting...');
      final token = await getToken();
      debugPrint('AuthService.refreshTokenIfNeeded - Token from storage: ${token != null}');
      debugPrint('AuthService.refreshTokenIfNeeded - Token length: ${token?.length}');
      
      if (token == null) {
        debugPrint('AuthService.refreshTokenIfNeeded - No token found, returning null');
        return null;
      }

      debugPrint('AuthService.refreshTokenIfNeeded - Testing token with profile endpoint...');
      // Coba refresh token dengan API call sederhana
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/user'), // GANTI KE ENDPOINT YANG BENAR
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('AuthService.refreshTokenIfNeeded - Profile test status: ${response.statusCode}');
      debugPrint('AuthService.refreshTokenIfNeeded - Profile test response: ${response.body}');

      if (response.statusCode == 200) {
        // Token masih valid
        debugPrint('AuthService.refreshTokenIfNeeded - Token is valid, returning token');
        return token;
      } else if (response.statusCode == 401) {
        // Token expired, coba refresh
        debugPrint('AuthService.refreshTokenIfNeeded - Token expired (401), attempting refresh...');
        return await _attemptTokenRefresh();
      }
      
      debugPrint('AuthService.refreshTokenIfNeeded - Other status code, returning token anyway');
      return token;
    } catch (e) {
      debugPrint('AuthService.refreshTokenIfNeeded - Error: $e');
      // Jika gagal, hapus token dan return null
      await removeToken();
      debugPrint('AuthService.refreshTokenIfNeeded - Token removed due to error');
      return null;
    }
  }

  // Mencoba refresh token
  static Future<String?> _attemptTokenRefresh() async {
    try {
      // Implementasi refresh token bisa ditambahkan di sini
      // Untuk sementara, kita hapus token dan minta login ulang
      await removeToken();
      return null;
    } catch (e) {
      await removeToken();
      return null;
    }
  }

  // Menyimpan data user ke SharedPreferences
  static Future<void> saveUser(Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(userJson));
  }

  // Mengambil data user dari SharedPreferences
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr == null) return null;
    return jsonDecode(userStr) as Map<String, dynamic>;
  }

  // Fungsi login
  static Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(responseData);
        
        // Jika login berhasil, simpan token dan user
        if (loginResponse.status && loginResponse.data != null) {
          await saveToken(loginResponse.data!.token);
          await saveUser(loginResponse.data!.user.toJson());
        }
        
        return loginResponse;
      } else {
        // Handle error response
        return LoginResponse.fromJson(responseData);
      }
    } catch (e) {
      // Handle network error atau error lainnya
      return LoginResponse(
        status: false,
        message: 'Terjadi kesalahan koneksi: $e',
      );
    }
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Fungsi register
  static Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.registerEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
          'address': address,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final registerResponse = RegisterResponse.fromJson(responseData);
        // Jangan simpan token setelah register
        return registerResponse;
      } else {
        // Handle error response
        return RegisterResponse.fromJson(responseData);
      }
    } catch (e) {
      // Handle network error atau error lainnya
      return RegisterResponse(
        success: false,
        message: 'Terjadi kesalahan koneksi: $e',
      );
    }
  }

  // Fungsi ganti password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan, silakan login ulang',
        };
      }

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/api/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password berhasil diubah',
        };
      } else {
        // Handle error response
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal mengubah password',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      // Handle network error atau error lainnya
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> simpleResetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/auth/simple-reset-password');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Gagal reset password');
    }
  }
} 