import 'package:dio/dio.dart';
import '../../../core/constants.dart';

class AddressService {
  static Future<List<dynamic>> getAddresses(String token) async {
    final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
    final response = await dio.get(
      '/api/addresses',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }),
    );
    final isSuccess = response.data['success'] == true || response.data['success'] == 'true' || response.data['status'] == true;
    if (response.statusCode == 200 && isSuccess) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Gagal mengambil alamat');
    }
  }

  static Future<bool> addAddress(String token, Map<String, dynamic> data) async {
    final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
    final response = await dio.post(
      '/api/addresses',
      data: data,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }),
    );
    final isSuccess = response.data['success'] == true || response.data['success'] == 'true' || response.data['status'] == true;
    if (response.statusCode == 200 && isSuccess) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'Gagal tambah alamat');
    }
  }

  static Future<bool> editAddress(String token, int id, Map<String, dynamic> data) async {
    final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
    final response = await dio.put(
      '/api/addresses/$id',
      data: data,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }),
    );
    final isSuccess = response.data['success'] == true || response.data['success'] == 'true' || response.data['status'] == true;
    if (response.statusCode == 200 && isSuccess) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'Gagal edit alamat');
    }
  }

  static Future<bool> deleteAddress(String token, int id) async {
    final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
    final response = await dio.delete(
      '/api/addresses/$id',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }),
    );
    final isSuccess = response.data['success'] == true || response.data['success'] == 'true' || response.data['status'] == true;
    if (response.statusCode == 200 && isSuccess) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'Gagal hapus alamat');
    }
  }
} 