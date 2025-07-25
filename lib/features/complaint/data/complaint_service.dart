import 'dart:io';
import 'package:dio/dio.dart';
import 'complaint_model.dart';
import '../../../core/constants.dart';
import '../../auth/data/auth_service.dart';

class ComplaintService {
  final Dio _dio = Dio();
  bool _isSubmitting = false; // Untuk mencegah multiple submit

  ComplaintService() {
    _dio.options.baseUrl = '${AppConstants.baseUrl}/api';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  // Get token from auth service
  Future<String?> get _token async => await AuthService.getToken();

  // Submit complaint baru
  Future<Complaint> submitComplaint({
    required int orderId,
    required String reason,
    required String description,
    File? photo,
  }) async {
    // Mencegah multiple submit
    if (_isSubmitting) {
      print('Submit blocked at service level: already submitting');
      throw Exception('Sedang mengajukan komplain, silakan tunggu');
    }

    _isSubmitting = true;
    
    try {
      final token = await _token;
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      FormData formData = FormData.fromMap({
        'reason': reason,
        'description': description,
      });

      if (photo != null) {
        formData.files.add(
          MapEntry(
            'photo',
            await MultipartFile.fromFile(photo.path),
          ),
        );
      }

      print('Submitting complaint for order: $orderId');
      print('Reason: $reason');
      print('Description: $description');
      print('Photo: ${photo?.path}');

      final response = await _dio.post(
        '/orders/$orderId/complaints',
        data: formData,
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.data['success']) {
        return Complaint.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengajukan komplain');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        String errorMessage = 'Validasi gagal:\n';
        errors?.forEach((key, value) {
          errorMessage += '• ${value[0]}\n';
        });
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 401) {
        throw Exception('Token tidak valid');
      } else {
        throw Exception('Gagal mengajukan komplain: ${e.message}');
      }
    } catch (e) {
      print('General error: $e');
      print('Error type: ${e.runtimeType}');
      throw Exception('Terjadi kesalahan: $e');
    } finally {
      _isSubmitting = false;
    }
  }

  // Get list complaint per order
  Future<List<Complaint>> getComplaints(int orderId) async {
    try {
      final token = await _token;
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      print('Fetching complaints for order: $orderId');

      final response = await _dio.get('/orders/$orderId/complaints');

      print('Get complaints response status: ${response.statusCode}');
      print('Get complaints response data: ${response.data}');

      if (response.data['success']) {
        final complaintsList = response.data['data'] as List;
        print('Complaints count from API: ${complaintsList.length}');
        
        final complaints = complaintsList
            .map((json) => Complaint.fromJson(json))
            .toList();
            
        print('Parsed complaints count: ${complaints.length}');
        print('Complaint IDs: ${complaints.map((c) => c.id).toList()}');
        
        return complaints;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil data komplain');
      }
    } on DioException catch (e) {
      print('GetComplaints DioException: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Token tidak valid');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Order tidak ditemukan');
      } else {
        throw Exception('Gagal mengambil data komplain: ${e.message}');
      }
    } catch (e) {
      print('GetComplaints general error: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Get detail complaint
  Future<Complaint> getComplaintDetail(int complaintId) async {
    try {
      final token = await _token;
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get('/complaints/$complaintId');

      if (response.data['success']) {
        return Complaint.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil detail komplain');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Token tidak valid');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Komplain tidak ditemukan');
      } else {
        throw Exception('Gagal mengambil detail komplain: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Update status complaint (Admin only)
  Future<Complaint> updateComplaintStatus({
    required int complaintId,
    required String status,
    String? response,
  }) async {
    try {
      final token = await _token;
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final dioResponse = await _dio.put(
        '/complaints/$complaintId',
        data: {
          'status': status,
          if (response != null) 'response': response,
        },
      );

      if (dioResponse.data['success']) {
        return Complaint.fromJson(dioResponse.data['data']);
      } else {
        throw Exception(dioResponse.data['message'] ?? 'Gagal update status komplain');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Token tidak valid');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Tidak punya akses untuk update status');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Komplain tidak ditemukan');
      } else {
        throw Exception('Gagal update status komplain: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
} 