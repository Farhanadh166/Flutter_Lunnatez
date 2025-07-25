import 'package:flutter/material.dart';
import '../data/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class ProfileProvider extends ChangeNotifier {
  String name = '';
  String email = '';
  String photoUrl = '';
  String alamat = '';
  String phone = '';
  bool isLoading = false;
  bool isVerified = false;
  String joinDate = '';
  int totalOrder = 0;

  Future<void> fetchProfile(BuildContext context) async {
    debugPrint('Mulai ambil profil...');
    isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      debugPrint('Token: $token');
      if (token == null) throw Exception('Token tidak ditemukan');
      final data = await ProfileService.getProfile(token);
      debugPrint('Data profil: $data');
      name = data['name'] ?? '';
      email = data['email'] ?? '';
      photoUrl = data['photo_url'] ?? '';
      alamat = data['alamat'] ?? data['address'] ?? '';
      phone = data['phone'] ?? '';
      isVerified = data['is_verified'] == true || data['is_verified'] == 1;
      joinDate = data['join_date'] ?? data['created_at'] ?? '';
      totalOrder = data['total_order'] is int ? data['total_order'] : int.tryParse(data['total_order']?.toString() ?? '0') ?? 0;
    } catch (e) {
      debugPrint('Error ambil profil: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil profil: $e')),
      );
    }
    isLoading = false;
    notifyListeners();
  }
  Future<bool> updateProfile(BuildContext context, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');
      final result = await ProfileService.updateProfile(token, data);
      if (result) {
        await fetchProfile(context); // refresh data
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error update profil: $e');
      if (e is DioException && e.response?.data != null) {
        final data = e.response?.data;
        String msg = data['message'] ?? 'Gagal update profil';
        if (data['errors'] != null) {
          msg += '\n' + (data['errors'] as Map).values.map((v) => (v as List).join(', ')).join('\n');
        }
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
      return false;
    }
  }
  Future<bool> uploadPhoto(BuildContext context, String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token tidak ditemukan');
      final result = await ProfileService.uploadPhoto(token, filePath);
      if (result) {
        await fetchProfile(context); // refresh data
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error upload foto: $e');
      return false;
    }
  }
} 