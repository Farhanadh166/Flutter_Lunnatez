import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'payment_method.dart';
import 'bank_info.dart';
import 'payment_status.dart';
import '../../../core/constants.dart';
import '../../auth/data/auth_service.dart';

class PaymentService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (status) {
      return status != null && status < 500;
    },
    followRedirects: false,
  ));

  Future<List<PaymentMethod>> getPaymentMethods() async {
    debugPrint('PaymentService.getPaymentMethods - Starting...');
    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('PaymentService.getPaymentMethods - Token not found');
        throw Exception('Token tidak ditemukan');
      }

      final response = await _dio.get(
        '/api/payment/methods',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      debugPrint('PaymentService.getPaymentMethods - Status code: ${response.statusCode}');
      debugPrint('PaymentService.getPaymentMethods - Response: ${response.data}');
      
      // Handle redirect status codes
      if (response.statusCode == 302 || response.statusCode == 301) {
        debugPrint('PaymentService.getPaymentMethods - Redirect detected, likely token expired');
        // Jangan logout otomatis, hanya tampilkan pesan error
        throw Exception('Token tidak valid atau expired. Silakan login ulang.');
      }
      
      // Handle other error status codes
      if (response.statusCode != 200) {
        debugPrint('PaymentService.getPaymentMethods - Error status code: ${response.statusCode}');
        throw Exception('Gagal mengambil metode pembayaran: ${response.statusCode}');
      }
      
      // Validasi bahwa response.data adalah Map (JSON), bukan String (HTML)
      if (response.data is! Map<String, dynamic>) {
        debugPrint('PaymentService.getPaymentMethods - Response is not JSON, likely HTML login page');
        throw Exception('Token tidak valid atau expired. Silakan login ulang.');
      }
      
      if (response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        debugPrint('PaymentService.getPaymentMethods - Raw data: $data');
        
        final methods = data.map((json) {
          try {
            return PaymentMethod.fromJson(json);
          } catch (e, stackTrace) {
            debugPrint('PaymentService.getPaymentMethods - Error parsing item: $e');
            debugPrint('PaymentService.getPaymentMethods - Item JSON: $json');
            debugPrint('PaymentService.getPaymentMethods - Stack trace: $stackTrace');
            rethrow;
          }
        }).toList();
        
        debugPrint('PaymentService.getPaymentMethods - Parsed methods count: ${methods.length}');
        return methods;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil metode pembayaran');
      }
    } on DioException catch (e) {
      debugPrint('PaymentService.getPaymentMethods - DioException: ${e.message}');
      debugPrint('PaymentService.getPaymentMethods - DioException type: ${e.type}');
      debugPrint('PaymentService.getPaymentMethods - DioException status code: ${e.response?.statusCode}');
      
      // Handle specific DioException types
      if (e.type == DioExceptionType.badResponse) {
        if (e.response?.statusCode == 302 || e.response?.statusCode == 301) {
          // Jangan logout otomatis, hanya tampilkan pesan error
          throw Exception('Token tidak valid atau expired. Silakan login ulang.');
        }
        throw Exception('Server error: ${e.response?.statusCode}');
      }
      
      throw Exception('Error: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('PaymentService.getPaymentMethods - Unexpected error: $e');
      debugPrint('PaymentService.getPaymentMethods - Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<BankInfo>> getBankInfo() async {
    debugPrint('PaymentService.getBankInfo - Starting...');
    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('PaymentService.getBankInfo - Token not found');
        throw Exception('Token tidak ditemukan');
      }

      final response = await _dio.get(
        '/api/payment/bank-info',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      debugPrint('PaymentService.getBankInfo - Status code: ${response.statusCode}');
      debugPrint('PaymentService.getBankInfo - Response: ${response.data}');
      
      // Handle redirect status codes
      if (response.statusCode == 302 || response.statusCode == 301) {
        debugPrint('PaymentService.getBankInfo - Redirect detected, likely token expired');
        // Jangan logout otomatis, hanya tampilkan pesan error
        throw Exception('Token tidak valid atau expired. Silakan login ulang.');
      }
      
      // Handle other error status codes
      if (response.statusCode != 200) {
        debugPrint('PaymentService.getBankInfo - Error status code: ${response.statusCode}');
        throw Exception('Gagal mengambil info rekening: ${response.statusCode}');
      }
      
      // Validasi bahwa response.data adalah Map (JSON), bukan String (HTML)
      if (response.data is! Map<String, dynamic>) {
        debugPrint('PaymentService.getBankInfo - Response is not JSON, likely HTML login page');
        throw Exception('Token tidak valid atau expired. Silakan login ulang.');
      }
      
      if (response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        debugPrint('PaymentService.getBankInfo - Raw data: $data');
        
        final bankInfo = data.map((json) {
          try {
            return BankInfo.fromJson(json);
          } catch (e, stackTrace) {
            debugPrint('PaymentService.getBankInfo - Error parsing item: $e');
            debugPrint('PaymentService.getBankInfo - Item JSON: $json');
            debugPrint('PaymentService.getBankInfo - Stack trace: $stackTrace');
            rethrow;
          }
        }).toList();
        
        debugPrint('PaymentService.getBankInfo - Parsed bank info count: ${bankInfo.length}');
        return bankInfo;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil info rekening');
      }
    } on DioException catch (e) {
      debugPrint('PaymentService.getBankInfo - DioException: ${e.message}');
      debugPrint('PaymentService.getBankInfo - DioException type: ${e.type}');
      debugPrint('PaymentService.getBankInfo - DioException status code: ${e.response?.statusCode}');
      
      // Handle specific DioException types
      if (e.type == DioExceptionType.badResponse) {
        if (e.response?.statusCode == 302 || e.response?.statusCode == 301) {
          throw Exception('Token tidak valid atau expired. Silakan login ulang.');
        }
        throw Exception('Server error: ${e.response?.statusCode}');
      }
      
      throw Exception('Error: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('PaymentService.getBankInfo - Unexpected error: $e');
      debugPrint('PaymentService.getBankInfo - Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Upload proof of payment with token (default)
  Future<bool> uploadProof({
    required String orderId,
    required File imageFile,
    String? notes,
    bool useSession = false, // Opsi untuk upload tanpa token
  }) async {
    debugPrint('PaymentService.uploadProof - Starting for orderId: $orderId');
    debugPrint('PaymentService.uploadProof - Image path: ${imageFile.path}');
    debugPrint('PaymentService.uploadProof - Notes: $notes');
    debugPrint('PaymentService.uploadProof - Use session: $useSession');
    
    try {
      String? token;
      
      if (useSession) {
        // Gunakan session-based upload (tanpa token)
        debugPrint('PaymentService.uploadProof - Using session-based upload');
        token = null;
      } else {
        // Gunakan token-based upload (default)
        token = await _getToken();
        if (token == null) {
          debugPrint('PaymentService.uploadProof - Token not found');
          throw Exception('Token tidak ditemukan');
        }
      }

      // Validate file
      if (!_isValidImageFile(imageFile)) {
        debugPrint('PaymentService.uploadProof - Invalid image file');
        throw Exception('File tidak valid. Gunakan format JPEG, PNG, atau JPG dengan ukuran maksimal 2MB');
      }

      // Create form data
      final formData = FormData.fromMap({
        'order_id': orderId,
        'payment_proof': await MultipartFile.fromFile( // Ubah dari 'proof_image' ke 'payment_proof'
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (useSession) 'use_session': 'true', // Flag untuk backend
      });

      debugPrint('PaymentService.uploadProof - Sending request...');
      
      // Headers berdasarkan tipe upload
      final headers = <String, dynamic>{
        'Content-Type': 'multipart/form-data',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.post(
        '/api/payment/upload-proof',
        data: formData,
        options: Options(headers: headers),
      );

      debugPrint('PaymentService.uploadProof - Status code: ${response.statusCode}');
      debugPrint('PaymentService.uploadProof - Response: ${response.data}');

      // Handle redirect status codes
      if (response.statusCode == 302 || response.statusCode == 301) {
        debugPrint('PaymentService.uploadProof - Redirect detected, likely token expired');
        // Jangan logout otomatis, hanya tampilkan pesan error
        throw Exception('Token tidak valid atau expired. Silakan login ulang.');
      }
      
      // Handle other error status codes
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('PaymentService.uploadProof - Error status code: ${response.statusCode}');
        throw Exception('Gagal upload bukti transfer: ${response.statusCode}');
      }

      // Validasi bahwa response.data adalah Map (JSON), bukan String (HTML)
      if (response.data is! Map<String, dynamic>) {
        debugPrint('PaymentService.uploadProof - Response is not JSON, likely HTML login page');
        throw Exception('Token tidak valid atau expired. Silakan login ulang.');
      }

      if (response.data['status'] == true) {
        debugPrint('PaymentService.uploadProof - Success');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal upload bukti transfer');
      }
    } on DioException catch (e) {
      debugPrint('PaymentService.uploadProof - DioException: ${e.message}');
      debugPrint('PaymentService.uploadProof - DioException type: ${e.type}');
      debugPrint('PaymentService.uploadProof - DioException status code: ${e.response?.statusCode}');
      
      // Handle specific DioException types
      if (e.type == DioExceptionType.badResponse) {
        if (e.response?.statusCode == 302 || e.response?.statusCode == 301) {
          // Jangan logout otomatis, hanya tampilkan pesan error
          throw Exception('Token tidak valid atau expired. Silakan login ulang.');
        }
        throw Exception('Server error: ${e.response?.statusCode}');
      }
      
      throw Exception('Error: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('PaymentService.uploadProof - Unexpected error: $e');
      debugPrint('PaymentService.uploadProof - Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Validate order ID with backend using new endpoint
  Future<bool> validateOrderId(String orderId) async {
    debugPrint('PaymentService.validateOrderId - Starting for orderId: $orderId');
    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('PaymentService.validateOrderId - Token not found');
        return false;
      }

      // Gunakan endpoint baru sesuai dokumentasi backend
      final response = await _dio.get(
        '/api/orders/by-number/$orderId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      debugPrint('PaymentService.validateOrderId - Status code: ${response.statusCode}');
      debugPrint('PaymentService.validateOrderId - Response: ${response.data}');
      
      if (response.statusCode == 200) {
        // Cek response format sesuai dokumentasi
        if (response.data is Map<String, dynamic> && 
            response.data['status'] == true) {
          debugPrint('PaymentService.validateOrderId - Order found and valid');
          return true;
        } else {
          debugPrint('PaymentService.validateOrderId - Order not found in response');
          return false;
        }
      } else {
        debugPrint('PaymentService.validateOrderId - Order not found (status: ${response.statusCode})');
        return false;
      }
    } catch (e) {
      debugPrint('PaymentService.validateOrderId - Error: $e');
      return false;
    }
  }

  // Upload proof of payment without login (public endpoint)
  Future<Map<String, dynamic>> uploadProofWithoutLogin({
    required String orderId,
    required File imageFile,
    String? notes,
  }) async {
    debugPrint('PaymentService.uploadProofWithoutLogin - Starting for orderId: $orderId');
    debugPrint('PaymentService.uploadProofWithoutLogin - Image path: ${imageFile.path}');
    debugPrint('PaymentService.uploadProofWithoutLogin - Notes: $notes');
    debugPrint('PaymentService.uploadProofWithoutLogin - Image file exists: ${await imageFile.exists()}');
    debugPrint('PaymentService.uploadProofWithoutLogin - Image file size: ${await imageFile.length()} bytes');
    debugPrint('PaymentService.uploadProofWithoutLogin - Order ID validation: ${orderId.isNotEmpty}');
    debugPrint('PaymentService.uploadProofWithoutLogin - Order ID format: ${orderId.startsWith('ORD-')}');
    debugPrint('PaymentService.uploadProofWithoutLogin - Order ID length: ${orderId.length}');
    debugPrint('PaymentService.uploadProofWithoutLogin - Order ID full: $orderId');
    
    try {
      // Get token for authentication
      final token = await _getToken();
      debugPrint('PaymentService.uploadProofWithoutLogin - Token found: ${token != null}');
      debugPrint('PaymentService.uploadProofWithoutLogin - Token value: ${token?.substring(0, 20)}...');
      
      if (token == null) {
        debugPrint('PaymentService.uploadProofWithoutLogin - No token available');
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      if (token.isEmpty) {
        debugPrint('PaymentService.uploadProofWithoutLogin - Token is empty');
        throw Exception('Token kosong. Silakan login ulang.');
      }

      // Validate file
      if (!_isValidImageFile(imageFile)) {
        debugPrint('PaymentService.uploadProofWithoutLogin - Invalid image file');
        throw Exception('File tidak valid. Gunakan format JPEG, PNG, atau JPG dengan ukuran maksimal 2MB');
      }

      // Validate order ID format
      if (!orderId.startsWith('ORD-')) {
        debugPrint('PaymentService.uploadProofWithoutLogin - Invalid order ID format');
        throw Exception('Format Order ID tidak valid. Harus dimulai dengan ORD-');
      }
      
      if (orderId.length < 10) {
        debugPrint('PaymentService.uploadProofWithoutLogin - Order ID too short');
        throw Exception('Order ID terlalu pendek');
      }

      // Validate order ID with backend
      debugPrint('PaymentService.uploadProofWithoutLogin - Validating order ID with backend...');
      final isOrderValid = await validateOrderId(orderId);
      if (!isOrderValid) {
        debugPrint('PaymentService.uploadProofWithoutLogin - Order ID not found in backend');
        throw Exception('Order ID tidak ditemukan di sistem. Pastikan order sudah dibuat.');
      }
      debugPrint('PaymentService.uploadProofWithoutLogin - Order ID validated successfully');

      // Create form data sesuai dokumentasi backend
      final formData = FormData.fromMap({
        'order_id': orderId, // Menggunakan order_number
        'payment_proof': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });

      debugPrint('PaymentService.uploadProofWithoutLogin - Form data created');
      debugPrint('PaymentService.uploadProofWithoutLogin - Order ID: $orderId');
      debugPrint('PaymentService.uploadProofWithoutLogin - Notes included: ${notes != null && notes.isNotEmpty}');
      debugPrint('PaymentService.uploadProofWithoutLogin - Public upload flag: true');
      debugPrint('PaymentService.uploadProofWithoutLogin - File field name: payment_proof');
      debugPrint('PaymentService.uploadProofWithoutLogin - File name: ${imageFile.path.split('/').last}');

      debugPrint('PaymentService.uploadProofWithoutLogin - Sending request...');
      debugPrint('PaymentService.uploadProofWithoutLogin - URL: ${_dio.options.baseUrl}/api/payment/upload-proof');
      
      // Headers dengan Authorization
      final headers = <String, dynamic>{
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      debugPrint('PaymentService.uploadProofWithoutLogin - Headers: $headers');
      debugPrint('PaymentService.uploadProofWithoutLogin - Authorization header: Bearer $token');
      debugPrint('PaymentService.uploadProofWithoutLogin - Token length: ${token.length}');

      final response = await _dio.post(
        '/api/payment/upload-proof', // Gunakan endpoint yang sudah ada
        data: formData,
        options: Options(headers: headers),
      );

      debugPrint('PaymentService.uploadProofWithoutLogin - Status code: ${response.statusCode}');
      debugPrint('PaymentService.uploadProofWithoutLogin - Response headers: ${response.headers}');
      debugPrint('PaymentService.uploadProofWithoutLogin - Response data type: ${response.data.runtimeType}');
      debugPrint('PaymentService.uploadProofWithoutLogin - Response: ${response.data}');
      
      // Handle error status codes
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('PaymentService.uploadProofWithoutLogin - Error status code: ${response.statusCode}');
        debugPrint('PaymentService.uploadProofWithoutLogin - Error response: ${response.data}');
        throw Exception('Gagal upload bukti transfer: ${response.statusCode} - ${response.data}');
      }

      // Validasi bahwa response.data adalah Map (JSON), bukan String (HTML)
      if (response.data is! Map<String, dynamic>) {
        debugPrint('PaymentService.uploadProofWithoutLogin - Response is not JSON');
        debugPrint('PaymentService.uploadProofWithoutLogin - Response type: ${response.data.runtimeType}');
        debugPrint('PaymentService.uploadProofWithoutLogin - Response content: ${response.data}');
        throw Exception('Response tidak valid dari server: ${response.data}');
      }

      debugPrint('PaymentService.uploadProofWithoutLogin - Response is valid JSON');
      debugPrint('PaymentService.uploadProofWithoutLogin - Response status: ${response.data['status']}');
      debugPrint('PaymentService.uploadProofWithoutLogin - Response message: ${response.data['message']}');

      // Handle response sesuai dokumentasi backend
      if (response.data['status'] == true) {
        debugPrint('PaymentService.uploadProofWithoutLogin - Success');
        debugPrint('PaymentService.uploadProofWithoutLogin - Payment proof URL: ${response.data['data']?['payment_proof_url']}');
        return response.data;
      } else {
        final errorMessage = response.data['message'] ?? 'Gagal upload bukti transfer';
        debugPrint('PaymentService.uploadProofWithoutLogin - Server error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('PaymentService.uploadProofWithoutLogin - DioException: ${e.message}');
      debugPrint('PaymentService.uploadProofWithoutLogin - DioException type: ${e.type}');
      debugPrint('PaymentService.uploadProofWithoutLogin - DioException status code: ${e.response?.statusCode}');
      debugPrint('PaymentService.uploadProofWithoutLogin - DioException response: ${e.response?.data}');
      debugPrint('PaymentService.uploadProofWithoutLogin - DioException request: ${e.requestOptions.uri}');
      debugPrint('PaymentService.uploadProofWithoutLogin - DioException headers: ${e.requestOptions.headers}');
      
      // Handle specific DioException types
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        debugPrint('PaymentService.uploadProofWithoutLogin - Bad response: $statusCode - $responseData');
        
        // Handle 500 Internal Server Error - kemungkinan masalah folder penyimpanan
        if (statusCode == 500) {
          debugPrint('PaymentService.uploadProofWithoutLogin - 500 Internal Server Error detected');
          debugPrint('PaymentService.uploadProofWithoutLogin - File path: ${imageFile.path}');
          debugPrint('PaymentService.uploadProofWithoutLogin - File exists: ${await imageFile.exists()}');
          debugPrint('PaymentService.uploadProofWithoutLogin - File size: ${await imageFile.length()} bytes');
          debugPrint('PaymentService.uploadProofWithoutLogin - File name: ${imageFile.path.split('/').last}');
          debugPrint('PaymentService.uploadProofWithoutLogin - Order ID: $orderId');
          debugPrint('PaymentService.uploadProofWithoutLogin - Notes: $notes');
          
          // Coba berikan pesan error yang lebih spesifik
          if (responseData is Map<String, dynamic>) {
            final message = responseData['message'];
            final error = responseData['error'];
            debugPrint('PaymentService.uploadProofWithoutLogin - Server message: $message');
            debugPrint('PaymentService.uploadProofWithoutLogin - Server error: $error');
            
            if (message != null) {
              throw Exception('Server error: $message');
            } else if (error != null) {
              throw Exception('Server error: $error');
            }
          }
          
          throw Exception('Server error. Kemungkinan masalah folder penyimpanan foto di backend. Silakan hubungi admin.');
        }
        
        // Handle token expired/unauthorized sesuai dokumentasi
        if (statusCode == 401 && responseData is Map<String, dynamic>) {
          final message = responseData['message'];
          if (message == 'Unauthenticated') {
            throw Exception('Sesi Anda telah berakhir. Silakan login ulang.');
          }
        }
        
        // Handle validation errors
        if (statusCode == 422 && responseData is Map<String, dynamic>) {
          final message = responseData['message'];
          if (message != null) {
            throw Exception(message);
          }
        }
        
        // Handle order not found
        if (statusCode == 404 && responseData is Map<String, dynamic>) {
          final message = responseData['message'];
          if (message != null) {
            throw Exception(message);
          }
        }
        
        throw Exception('Server error: $statusCode - ${responseData is Map ? responseData['message'] : responseData}');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        debugPrint('PaymentService.uploadProofWithoutLogin - Connection timeout');
        throw Exception('Koneksi timeout. Periksa internet Anda.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        debugPrint('PaymentService.uploadProofWithoutLogin - Receive timeout');
        throw Exception('Server tidak merespons. Coba lagi.');
      } else if (e.type == DioExceptionType.connectionError) {
        debugPrint('PaymentService.uploadProofWithoutLogin - Connection error');
        throw Exception('Tidak dapat terhubung ke server. Periksa internet Anda.');
      }
      
      throw Exception('Error koneksi: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('PaymentService.uploadProofWithoutLogin - Unexpected error: $e');
      debugPrint('PaymentService.uploadProofWithoutLogin - Error type: ${e.runtimeType}');
      debugPrint('PaymentService.uploadProofWithoutLogin - Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<PaymentStatus> getPaymentStatus(String orderId) async {
    debugPrint('PaymentService.getPaymentStatus - Starting for orderId: $orderId');
    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('PaymentService.getPaymentStatus - Token not found');
        throw Exception('Token tidak ditemukan');
      }

      final response = await _dio.get(
        '/api/payment/status/$orderId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      debugPrint('PaymentService.getPaymentStatus - Status code: ${response.statusCode}');
      debugPrint('PaymentService.getPaymentStatus - Response: ${response.data}');

      // Handle redirect status codes
      if (response.statusCode == 302 || response.statusCode == 301) {
        debugPrint('PaymentService.getPaymentStatus - Redirect detected, likely token expired');
        // Jangan logout otomatis, hanya tampilkan pesan error
        throw Exception('Token tidak valid atau expired. Silakan login ulang.');
      }
      
      // Handle 404 Not Found
      if (response.statusCode == 404) {
        final msg = response.data is Map<String, dynamic> && response.data['message'] != null
            ? response.data['message']
            : 'Pesanan tidak ditemukan';
        throw Exception(msg);
      }

      // Handle other error status codes
      if (response.statusCode != 200) {
        debugPrint('PaymentService.getPaymentStatus - Error status code: ${response.statusCode}');
        throw Exception('Gagal mengambil status pembayaran: ${response.statusCode}');
      }

      // Validasi bahwa response.data adalah Map (JSON), bukan String (HTML)
      if (response.data is! Map<String, dynamic>) {
        debugPrint('PaymentService.getPaymentStatus - Response is not JSON, likely HTML login page');
        throw Exception('Token tidak valid atau expired. Silakan login ulang.');
      }

      if (response.data['status'] == true) {
        try {
          final paymentStatus = PaymentStatus.fromJson(response.data['data']);
          debugPrint('PaymentService.getPaymentStatus - Success, status: ${paymentStatus.status}');
          return paymentStatus;
        } catch (e, stackTrace) {
          debugPrint('PaymentService.getPaymentStatus - Error parsing response: $e');
          debugPrint('PaymentService.getPaymentStatus - Response data: ${response.data['data']}');
          debugPrint('PaymentService.getPaymentStatus - Stack trace: $stackTrace');
          rethrow;
        }
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil status pembayaran');
      }
    } on DioException catch (e) {
      debugPrint('PaymentService.getPaymentStatus - DioException: ${e.message}');
      debugPrint('PaymentService.getPaymentStatus - DioException type: ${e.type}');
      debugPrint('PaymentService.getPaymentStatus - DioException status code: ${e.response?.statusCode}');
      // Handle 404 dari DioException
      if (e.response?.statusCode == 404) {
        final msg = e.response?.data is Map<String, dynamic> && e.response?.data['message'] != null
            ? e.response?.data['message']
            : 'Pesanan tidak ditemukan';
        throw Exception(msg);
      }
      // Handle specific DioException types
      if (e.type == DioExceptionType.badResponse) {
        if (e.response?.statusCode == 302 || e.response?.statusCode == 301) {
          throw Exception('Token tidak valid atau expired. Silakan login ulang.');
        }
        throw Exception('Server error: ${e.response?.statusCode}');
      }
      throw Exception('Error: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('PaymentService.getPaymentStatus - Unexpected error: $e');
      debugPrint('PaymentService.getPaymentStatus - Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String?> _getToken() async {
    try {
      debugPrint('PaymentService._getToken - Starting...');
      // Gunakan auto-refresh token
      final token = await AuthService.refreshTokenIfNeeded();
      debugPrint('PaymentService._getToken - Token found: ${token != null}');
      debugPrint('PaymentService._getToken - Token length: ${token?.length}');
      debugPrint('PaymentService._getToken - Token preview: ${token?.substring(0, 20)}...');
      return token;
    } catch (e, stackTrace) {
      debugPrint('PaymentService._getToken - Error: $e');
      debugPrint('PaymentService._getToken - Stack trace: $stackTrace');
      return null;
    }
  }

  bool _isValidImageFile(File file) {
    try {
      final validExtensions = ['.jpg', '.jpeg', '.png'];
      final fileName = file.path.toLowerCase();
      final hasValidExtension = validExtensions.any((ext) => fileName.endsWith(ext));
      
      if (!hasValidExtension) {
        debugPrint('PaymentService._isValidImageFile - Invalid extension: $fileName');
        return false;
      }
      
      final fileSize = file.lengthSync();
      final maxSize = 2 * 1024 * 1024; // 2MB
      
      debugPrint('PaymentService._isValidImageFile - File size: $fileSize bytes, Max: $maxSize bytes');
      return fileSize <= maxSize;
    } catch (e, stackTrace) {
      debugPrint('PaymentService._isValidImageFile - Error: $e');
      debugPrint('PaymentService._isValidImageFile - Stack trace: $stackTrace');
      return false;
    }
  }


} 