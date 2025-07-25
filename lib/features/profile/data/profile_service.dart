import 'package:dio/dio.dart';
import '../../../core/constants.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
    final response = await dio.get(
      '/api/profile',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Gagal mengambil profil');
    }
  }
  static Future<bool> updateProfile(String token, Map<String, dynamic> data) async {
    final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
    final response = await dio.put(
      '/api/profile',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
    final isSuccess = response.data['success'] == true || response.data['success'] == 'true' || response.data['status'] == true;
    if (response.statusCode == 200 && isSuccess) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'Gagal update profil');
    }
  }
  static Future<bool> uploadPhoto(String token, String filePath) async {
    final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
    final file = await MultipartFile.fromFile(filePath);
    final fileName = filePath.split('/').last.toLowerCase();
    if (!(fileName.endsWith('.jpg') || fileName.endsWith('.jpeg') || fileName.endsWith('.png'))) {
      throw Exception('Format file harus jpg, jpeg, atau png');
    }
    final formData = FormData.fromMap({'photo': file});
    final response = await dio.post(
      '/api/profile/photo',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'Gagal upload foto');
    }
  }
} 