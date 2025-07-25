import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'order_model.dart';
import '../../../core/constants.dart';
import '../../auth/data/auth_service.dart';
import 'package:dio/dio.dart';

class OrderService {
  static Future<String?> getToken() async {
    try {
      // Gunakan auto-refresh token
      final token = await AuthService.refreshTokenIfNeeded();
      debugPrint('OrderService.getToken - Token found: ${token != null}');
      return token;
    } catch (e, stackTrace) {
      debugPrint('OrderService.getToken - Error: $e');
      debugPrint('OrderService.getToken - Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<List<Address>> getAddresses() async {
    debugPrint('OrderService.getAddresses - Starting...');
    try {
      final token = await getToken();
      if (token == null) {
        debugPrint('OrderService.getAddresses - Token not found');
        throw Exception('Token tidak ditemukan');
      }

      final res = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/addresses'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      debugPrint('OrderService.getAddresses - Status code: ${res.statusCode}');
      debugPrint('OrderService.getAddresses - Response body: ${res.body}');
      
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        debugPrint('OrderService.getAddresses - Parsed data: $data');
        
        if (data['status'] == true) {
          final addresses = (data['data'] as List).map((e) {
            try {
              return Address.fromJson(e);
            } catch (e, stackTrace) {
              debugPrint('OrderService.getAddresses - Error parsing address: $e');
              debugPrint('OrderService.getAddresses - Address JSON: $e');
              debugPrint('OrderService.getAddresses - Stack trace: $stackTrace');
              rethrow;
            }
          }).toList();
          
          debugPrint('OrderService.getAddresses - Parsed addresses count: ${addresses.length}');
          return addresses;
        }
      }
      throw Exception('Gagal mengambil alamat');
    } catch (e, stackTrace) {
      debugPrint('OrderService.getAddresses - Error: $e');
      debugPrint('OrderService.getAddresses - Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<ShippingMethod>> getShippingMethods() async {
    debugPrint('OrderService.getShippingMethods - Starting...');
    try {
      final token = await getToken();
      if (token == null) {
        debugPrint('OrderService.getShippingMethods - Token not found');
        throw Exception('Token tidak ditemukan');
      }

      final res = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/shipping/methods'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      debugPrint('OrderService.getShippingMethods - Status code: ${res.statusCode}');
      debugPrint('OrderService.getShippingMethods - Response body: ${res.body}');
      
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        debugPrint('OrderService.getShippingMethods - Parsed data: $data');
        
        if (data['status'] == true) {
          final shippingMethods = (data['data'] as List).map((e) {
            try {
              return ShippingMethod.fromJson(e);
            } catch (e, stackTrace) {
              debugPrint('OrderService.getShippingMethods - Error parsing shipping method: $e');
              debugPrint('OrderService.getShippingMethods - Shipping method JSON: $e');
              debugPrint('OrderService.getShippingMethods - Stack trace: $stackTrace');
              rethrow;
            }
          }).toList();
          
          debugPrint('OrderService.getShippingMethods - Parsed shipping methods count: ${shippingMethods.length}');
          return shippingMethods;
        }
      }
      throw Exception('Gagal mengambil metode pengiriman');
    } catch (e, stackTrace) {
      debugPrint('OrderService.getShippingMethods - Error: $e');
      debugPrint('OrderService.getShippingMethods - Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<PaymentMethod>> getPaymentMethods() async {
    debugPrint('OrderService.getPaymentMethods - Starting...');
    try {
      final token = await getToken();
      if (token == null) {
        debugPrint('OrderService.getPaymentMethods - Token not found');
        throw Exception('Token tidak ditemukan');
      }

      final res = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.paymentMethodsEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      debugPrint('OrderService.getPaymentMethods - Status code: ${res.statusCode}');
      debugPrint('OrderService.getPaymentMethods - Response body: ${res.body}');
      
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        debugPrint('OrderService.getPaymentMethods - Parsed data: $data');
        
        if (data['status'] == true) {
          final paymentMethods = (data['data'] as List).map((e) {
            try {
              return PaymentMethod.fromJson(e);
            } catch (e, stackTrace) {
              debugPrint('OrderService.getPaymentMethods - Error parsing payment method: $e');
              debugPrint('OrderService.getPaymentMethods - Payment method JSON: $e');
              debugPrint('OrderService.getPaymentMethods - Stack trace: $stackTrace');
              rethrow;
            }
          }).toList();
          
          debugPrint('OrderService.getPaymentMethods - Parsed payment methods count: ${paymentMethods.length}');
          return paymentMethods;
        }
      }
      throw Exception('Gagal mengambil metode pembayaran');
    } catch (e, stackTrace) {
      debugPrint('OrderService.getPaymentMethods - Error: $e');
      debugPrint('OrderService.getPaymentMethods - Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<OrderResponse> checkoutOrder({
    required String addressId,
    required String shippingMethod,
    required String paymentMethod,
    String? notes,
  }) async {
    debugPrint('OrderService.checkoutOrder - Starting...');
    debugPrint('OrderService.checkoutOrder - addressId: $addressId');
    debugPrint('OrderService.checkoutOrder - shippingMethod: $shippingMethod');
    debugPrint('OrderService.checkoutOrder - paymentMethod: $paymentMethod');
    debugPrint('OrderService.checkoutOrder - notes: $notes');
    
    try {
      final token = await getToken();
      if (token == null) {
        debugPrint('OrderService.checkoutOrder - Token not found');
        throw Exception('Token tidak ditemukan');
      }

      final requestBody = {
        'address_id': addressId,
        'shipping_method': shippingMethod,
        'payment_method': paymentMethod,
        if (notes != null) 'notes': notes,
      };
      
      debugPrint('OrderService.checkoutOrder - Request body: $requestBody');

      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.ordersEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      debugPrint('OrderService.checkoutOrder - Status code: ${res.statusCode}');
      debugPrint('OrderService.checkoutOrder - Response body: ${res.body}');
      
      final data = json.decode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (data['status'] == true) {
          try {
            // Validasi response data
            if (data['data'] == null) {
              debugPrint('OrderService.checkoutOrder - Error: data is null');
              throw Exception('Response data tidak valid: data kosong');
            }
            
            // Cek apakah orderId ada dan tidak kosong
            final orderData = data['data'] as Map<String, dynamic>;
            final orderId = orderData['id']?.toString() ?? orderData['order_id']?.toString() ?? '';
            debugPrint('OrderService.checkoutOrder - Raw orderId from response: $orderId');
            
            if (orderId.isEmpty) {
              debugPrint('OrderService.checkoutOrder - Error: orderId is empty');
              throw Exception('Order ID tidak valid dari backend');
            }
            
            final orderResponse = OrderResponse.fromJson(data);
            debugPrint('OrderService.checkoutOrder - Success, order ID: ${orderResponse.data?.orderId}');
            
            // Double check orderId setelah parsing
            if (orderResponse.data?.orderId.isEmpty ?? true) {
              debugPrint('OrderService.checkoutOrder - Error: orderId still empty after parsing');
              throw Exception('Order ID tidak valid setelah parsing');
            }
            
            return orderResponse;
          } catch (e, stackTrace) {
            debugPrint('OrderService.checkoutOrder - Error parsing response: $e');
            debugPrint('OrderService.checkoutOrder - Response data: $data');
            debugPrint('OrderService.checkoutOrder - Stack trace: $stackTrace');
            rethrow;
          }
        } else {
          throw Exception(data['message'] ?? 'Gagal checkout');
        }
      } else {
        throw Exception(data['message'] ?? 'Gagal checkout');
      }
    } catch (e, stackTrace) {
      debugPrint('OrderService.checkoutOrder - Error: $e');
      debugPrint('OrderService.checkoutOrder - Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<Order>> getOrderHistory() async {
    debugPrint('OrderService.getOrderHistory - Starting...');
    try {
      final token = await getToken();
      if (token == null) {
        debugPrint('OrderService.getOrderHistory - Token not found');
        throw Exception('Token tidak ditemukan');
      }

      final res = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/orders/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      debugPrint('OrderService.getOrderHistory - Status code: ${res.statusCode}');
      debugPrint('OrderService.getOrderHistory - Response body: ${res.body}');
      
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        debugPrint('OrderService.getOrderHistory - Parsed data: $data');
        
        if (data['status'] == true) {
          final orders = (data['data'] as List).map((e) {
            try {
              return Order.fromJson(e);
            } catch (e, stackTrace) {
              debugPrint('OrderService.getOrderHistory - Error parsing order: $e');
              debugPrint('OrderService.getOrderHistory - Order JSON: $e');
              debugPrint('OrderService.getOrderHistory - Stack trace: $stackTrace');
              rethrow;
            }
          }).toList();
          
          debugPrint('OrderService.getOrderHistory - Parsed orders count: ${orders.length}');
          return orders;
        }
      }
      throw Exception('Gagal mengambil riwayat pesanan');
    } catch (e, stackTrace) {
      debugPrint('OrderService.getOrderHistory - Error: $e');
      debugPrint('OrderService.getOrderHistory - Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<Map<String, List<Order>>> getOrderHistoryGrouped() async {
    debugPrint('OrderService.getOrderHistoryGrouped - Starting...');
    try {
      final token = await getToken();
      debugPrint('OrderService.getOrderHistoryGrouped - Token: ' + (token ?? 'NULL'));
      if (token == null) throw Exception('Token tidak ditemukan');
      final res = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/orders/history-grouped'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      debugPrint('OrderService.getOrderHistoryGrouped - Status code: ${res.statusCode}');
      debugPrint('OrderService.getOrderHistoryGrouped - Response body: ${res.body}');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        debugPrint('OrderService.getOrderHistoryGrouped - Decoded data: ${data.toString()}');
        if (data['success'] == true) {
          final Map<String, List<Order>> grouped = {};
          (data['data'] as Map<String, dynamic>).forEach((status, list) {
            grouped[status] = (list as List).map((e) => Order.fromJson(e)).toList();
          });
          debugPrint('OrderService.getOrderHistoryGrouped - Parsed grouped: ${grouped.keys}');
          return grouped;
        }
      }
      throw Exception('Gagal mengambil riwayat pesanan');
    } catch (e, stackTrace) {
      debugPrint('OrderService.getOrderHistoryGrouped - Error: $e');
      debugPrint('OrderService.getOrderHistoryGrouped - Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<Order> getOrderDetail(String id) async {
    debugPrint('OrderService.getOrderDetail - Starting...');
    debugPrint('OrderService.getOrderDetail - Order ID: $id');
    
    // Validasi ID tidak kosong
    if (id.isEmpty) {
      debugPrint('OrderService.getOrderDetail - Error: Order ID is empty');
      throw Exception('Order ID tidak boleh kosong');
    }
    
    try {
      final token = await getToken();
      debugPrint('OrderService.getOrderDetail - Token: ${token ?? 'NULL'}');
      if (token == null) throw Exception('Token tidak ditemukan');
      
      final url = '${AppConstants.baseUrl}/api/orders/$id';
      debugPrint('OrderService.getOrderDetail - URL: $url');
      
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      debugPrint('OrderService.getOrderDetail - Status code: ${res.statusCode}');
      debugPrint('OrderService.getOrderDetail - Response body: ${res.body}');
      
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        debugPrint('OrderService.getOrderDetail - Decoded data: $data');
        debugPrint('OrderService.getOrderDetail - Data type: ${data.runtimeType}');
        debugPrint('OrderService.getOrderDetail - Status field: ${data['status']}');
        debugPrint('OrderService.getOrderDetail - Data field exists: ${data.containsKey('data')}');
        debugPrint('OrderService.getOrderDetail - Data field type: ${data['data']?.runtimeType}');
        debugPrint('OrderService.getOrderDetail - Data field value: ${data['data']}');
        
        if (data['status'] == true && data['data'] != null && data['data'] is Map<String, dynamic>) {
          debugPrint('OrderService.getOrderDetail - Parsing order data...');
          final order = Order.fromJson(data['data']);
          debugPrint('OrderService.getOrderDetail - Order parsed successfully: ${order.orderId}');
          return order;
        } else {
          debugPrint('OrderService.getOrderDetail - Invalid response structure');
          debugPrint('OrderService.getOrderDetail - Status is true: ${data['status'] == true}');
          debugPrint('OrderService.getOrderDetail - Data is not null: ${data['data'] != null}');
          debugPrint('OrderService.getOrderDetail - Data is Map: ${data['data'] is Map<String, dynamic>}');
          throw Exception('Response tidak valid: data bukan objek');
        }
      } else {
        debugPrint('OrderService.getOrderDetail - HTTP Error: ${res.statusCode}');
        throw Exception('HTTP Error: ${res.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('OrderService.getOrderDetail - Error: $e');
      debugPrint('OrderService.getOrderDetail - Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> confirmOrderReceived(String id) async {
    debugPrint('OrderService.confirmOrderReceived - Starting...');
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token tidak ditemukan');
      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/orders/$id/confirm-received'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      debugPrint('OrderService.confirmOrderReceived - Status code: ${res.statusCode}');
      debugPrint('OrderService.confirmOrderReceived - Response body: ${res.body}');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          return true;
        }
      }
      throw Exception('Gagal konfirmasi pesanan diterima');
    } catch (e, stackTrace) {
      debugPrint('OrderService.confirmOrderReceived - Error: $e');
      debugPrint('OrderService.confirmOrderReceived - Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<Address> addAddress({
    required String name,
    required String phone,
    required String address,
    required String city,
    required String province,
    required String postalCode,
    bool isPrimary = false,
  }) async {
    debugPrint('OrderService.addAddress - Starting...');
    debugPrint('OrderService.addAddress - name: $name, city: $city, province: $province');
    
    try {
      final token = await getToken();
      if (token == null) {
        debugPrint('OrderService.addAddress - Token not found');
        throw Exception('Token tidak ditemukan');
      }

      final requestBody = {
        'name': name,
        'phone': phone,
        'address': address,
        'city': city,
        'province': province,
        'postal_code': postalCode,
        'is_primary': isPrimary,
      };
      
      debugPrint('OrderService.addAddress - Request body: $requestBody');

      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/addresses'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      debugPrint('OrderService.addAddress - Status code: ${res.statusCode}');
      debugPrint('OrderService.addAddress - Response body: ${res.body}');
      
      final data = json.decode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (data['status'] == true) {
          try {
            final newAddress = Address.fromJson(data['data']);
            debugPrint('OrderService.addAddress - Success, address ID: ${newAddress.id}');
            return newAddress;
          } catch (e, stackTrace) {
            debugPrint('OrderService.addAddress - Error parsing response: $e');
            debugPrint('OrderService.addAddress - Response data: ${data['data']}');
            debugPrint('OrderService.addAddress - Stack trace: $stackTrace');
            rethrow;
          }
        } else {
          throw Exception(data['message'] ?? 'Gagal tambah alamat');
        }
      } else {
        throw Exception(data['message'] ?? 'Gagal tambah alamat');
      }
    } catch (e, stackTrace) {
      debugPrint('OrderService.addAddress - Error: $e');
      debugPrint('OrderService.addAddress - Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> checkoutWithProof({
    required int addressId,
    required String shippingMethod,
    String? paymentMethod, // opsional
    String? notes,
    required List<Map<String, dynamic>> items,
    String? paymentProofPath, // opsional
    String? paymentNotes,
    required String token,
  }) async {
    final dio = Dio();
    final formData = FormData.fromMap({
      'address_id': addressId,
      'shipping_method': shippingMethod,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (notes != null) 'notes': notes,
      'items': items,
      if (paymentProofPath != null) 'payment_proof': await MultipartFile.fromFile(paymentProofPath, filename: paymentProofPath.split('/').last),
      if (paymentNotes != null) 'payment_notes': paymentNotes,
    });
    final response = await dio.post(
      '${AppConstants.baseUrl}/api/orders/checkout-with-proof',
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: 'multipart/form-data',
      ),
    );
    return response.data;
  }
} 