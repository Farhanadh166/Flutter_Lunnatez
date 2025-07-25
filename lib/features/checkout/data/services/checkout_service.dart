import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lunnatezz/core/constants.dart';
import 'package:lunnatezz/features/auth/data/auth_service.dart';
import 'package:lunnatezz/features/checkout/data/models/payment_method_model.dart';
import 'dart:io';

class CheckoutService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (status) {
      return status != null && status < 500;
    },
  ));

  Future<List<PaymentMethod>> getPaymentMethods() async {
    debugPrint('CheckoutService.getPaymentMethods - Starting...');
    try {
      final token = await AuthService.refreshTokenIfNeeded();
      if (token == null) {
        debugPrint('CheckoutService.getPaymentMethods - Token not found');
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final response = await _dio.get(
        '/api/payment/methods',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      debugPrint(
          'CheckoutService.getPaymentMethods - Status code: ${response.statusCode}');
      debugPrint(
          'CheckoutService.getPaymentMethods - Response: ${response.data}');

      if (response.statusCode != 200) {
        debugPrint(
            'CheckoutService.getPaymentMethods - Error status code: ${response.statusCode}');
        throw Exception(
            'Gagal mengambil metode pembayaran: ${response.statusCode}');
      }

      if (response.data is! Map<String, dynamic>) {
        debugPrint(
            'CheckoutService.getPaymentMethods - Response is not JSON, likely HTML login page');
        throw Exception('Sesi Anda telah berakhir. Silakan login ulang.');
      }

      if (response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        final methods = data.map((json) {
          return PaymentMethod.fromJson(json);
        }).toList();
        return methods;
      } else {
        throw Exception(
            response.data['message'] ?? 'Gagal mengambil metode pembayaran');
      }
    } on DioException catch (e) {
      debugPrint('CheckoutService.getPaymentMethods - DioException: ${e.message}');
      if (e.response?.statusCode == 401 || e.response?.statusCode == 302) {
        await AuthService.removeToken();
        throw Exception('Sesi Anda telah berakhir. Silakan login ulang.');
      }
      throw Exception('Error: ${e.message}');
    } catch (e) {
      debugPrint('CheckoutService.getPaymentMethods - Unexpected error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkout({
    required int addressId,
    required String shippingMethod,
    required String paymentMethod,
    String? notes,
  }) async {
    debugPrint('CheckoutService.checkout - Starting...');
    final token = await AuthService.refreshTokenIfNeeded();
    if (token == null) {
      debugPrint('CheckoutService.checkout - Token not found');
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    try {
      final response = await _dio.post(
        '/api/orders',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {
          'address_id': addressId,
          'shipping_method': shippingMethod,
          'payment_method': paymentMethod,
          if (notes != null) 'notes': notes,
        },
      );

      debugPrint('CheckoutService.checkout - Status code: ${response.statusCode}');
      debugPrint('CheckoutService.checkout - Response: ${response.data}');

      if (response.statusCode == 201) {
         if (response.data['status'] == true) {
          return response.data;
        } else {
          throw Exception(response.data['message'] ?? 'Gagal membuat pesanan.');
        }
      } else {
        throw Exception(
            response.data['message'] ?? 'Gagal membuat pesanan. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
       debugPrint('CheckoutService.checkout - DioException: ${e.message}');
       if (e.response?.statusCode == 401 || e.response?.statusCode == 302) {
        await AuthService.removeToken();
        throw Exception('Sesi Anda telah berakhir. Silakan login ulang.');
      }
       if(e.response?.data != null && e.response?.data['message'] != null){
         throw Exception(e.response!.data['message']);
       }
      throw Exception('Error: ${e.message}');
    } catch (e) {
      debugPrint('CheckoutService.checkout - Unexpected error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkoutWithProof({
    required int addressId,
    required String shippingMethod,
    required String paymentMethod,
    required List items,
    required File paymentProof,
    String? notes,
    String? paymentNotes,
  }) async {
    final token = await AuthService.refreshTokenIfNeeded();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }
    try {
      final formData = FormData.fromMap({
        'address_id': addressId,
        'shipping_method': shippingMethod,
        'payment_method': paymentMethod,
        'notes': notes,
        'payment_notes': paymentNotes,
        'payment_proof': await MultipartFile.fromFile(paymentProof.path, filename: paymentProof.path.split('/').last),
        ..._itemsToFormData(items),
      });
      final response = await _dio.post(
        '/api/orders/checkout-with-proof',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal membuat pesanan dengan bukti pembayaran.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 302) {
        await AuthService.removeToken();
        debugPrint('checkoutWithProof - Token expired/unauthorized, jangan logout otomatis.');
        throw Exception('Sesi Anda telah berakhir. Silakan login ulang.');
      }
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Map<String, dynamic> _itemsToFormData(List items) {
    final map = <String, dynamic>{};
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      map['items[$i][product_id]'] = item['product_id'];
      map['items[$i][qty]'] = item['qty'];
    }
    return map;
  }
} 