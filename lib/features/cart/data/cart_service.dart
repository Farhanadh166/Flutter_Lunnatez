import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'cart_item.dart';
import '../../../core/constants.dart';
import '../../auth/data/auth_service.dart';

class CartService {
  static String get baseUrl => AppConstants.baseUrl;

  static Future<String?> getToken() async {
    try {
      // Gunakan auto-refresh token
      final token = await AuthService.refreshTokenIfNeeded();
      debugPrint('CartService.getToken - Token found: ${token != null}');
      return token;
    } catch (e, stackTrace) {
      debugPrint('CartService.getToken - Error: $e');
      debugPrint('CartService.getToken - Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<Map<String, dynamic>> fetchCart() async {
    debugPrint('CartService.fetchCart - Starting...');
    final token = await getToken();
    if (token == null) {
      debugPrint('CartService.fetchCart - Token not found');
      throw Exception('Token tidak ditemukan');
    }

    try {
      final res = await http.get(
        Uri.parse('$baseUrl${AppConstants.cartEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('CartService.fetchCart - Status code: ${res.statusCode}');
      debugPrint('CartService.fetchCart - Response body: ${res.body}');

      if (res.statusCode == 401) {
        throw Exception('Token tidak valid atau expired');
      }

      if (res.statusCode != 200) {
        debugPrint('CartService.fetchCart - Error status: ${res.statusCode}');
        debugPrint('CartService.fetchCart - Error body: ${res.body}');
        throw Exception('Gagal mengambil data keranjang: ${res.statusCode}');
      }

      final data = json.decode(res.body);
      debugPrint('CartService.fetchCart - Parsed data: $data');
      
      if (data['status'] == true) {
        try {
          final List<CartItem> items = (data['data'] as List).map((e) {
            try {
              return CartItem.fromJson(e);
            } catch (e, stackTrace) {
              debugPrint('CartService.fetchCart - Error parsing cart item: $e');
              debugPrint('CartService.fetchCart - Item JSON: $e');
              debugPrint('CartService.fetchCart - Stack trace: $stackTrace');
              rethrow;
            }
          }).toList();
          
          debugPrint('CartService.fetchCart - Parsed items count: ${items.length}');
          
          final summary = data['summary'] ?? {};
          debugPrint('CartService.fetchCart - Summary: $summary');
          
          return {
            'items': items,
            'summary': {
              'total_items': summary['total_items'] ?? 0,
              'total_amount': summary['total_amount'] ?? 0,
            }
          };
        } catch (e, stackTrace) {
          debugPrint('CartService.fetchCart - Error processing response: $e');
          debugPrint('CartService.fetchCart - Stack trace: $stackTrace');
          rethrow;
        }
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil keranjang');
      }
    } catch (e, stackTrace) {
      debugPrint('CartService.fetchCart - Error: $e');
      debugPrint('CartService.fetchCart - Stack trace: $stackTrace');
      if (e is FormatException) {
        throw Exception('Response tidak valid: ${e.message}');
      }
      rethrow;
    }
  }

  static Future<CartItem> addToCart(int produkId, int quantity) async {
    debugPrint('CartService.addToCart - Starting...');
    debugPrint('CartService.addToCart - produkId: $produkId, quantity: $quantity');
    
    final token = await getToken();
    if (token == null) {
      debugPrint('CartService.addToCart - Token not found');
      throw Exception('Token tidak ditemukan');
    }

    try {
      final requestBody = {
        'produk_id': produkId, 
        'quantity': quantity
      };
      debugPrint('CartService.addToCart - Request body: $requestBody');

      final res = await http.post(
        Uri.parse('$baseUrl${AppConstants.cartEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      debugPrint('CartService.addToCart - Status code: ${res.statusCode}');
      debugPrint('CartService.addToCart - Response body: ${res.body}');

      if (res.statusCode == 401) {
        throw Exception('Token tidak valid atau expired');
      }

      // Ambil pesan error dari body jika status code bukan 200/201
      if (res.statusCode != 200 && res.statusCode != 201) {
        try {
          final data = json.decode(res.body);
          throw Exception(data['message'] ?? 'Gagal menambah ke keranjang:  {res.statusCode}');
        } catch (_) {
          throw Exception('Gagal menambah ke keranjang: ${res.statusCode}');
        }
      }

      final data = json.decode(res.body);
      debugPrint('CartService.addToCart - Parsed data: $data');
      
      if (data['status'] == true) {
        try {
          final cartItem = CartItem.fromJson(data['data']);
          debugPrint('CartService.addToCart - Success, item ID: ${cartItem.id}');
          return cartItem;
        } catch (e, stackTrace) {
          debugPrint('CartService.addToCart - Error parsing response: $e');
          debugPrint('CartService.addToCart - Response data: ${data['data']}');
          debugPrint('CartService.addToCart - Stack trace: $stackTrace');
          rethrow;
        }
      } else {
        throw Exception(data['message'] ?? 'Gagal menambah ke keranjang');
      }
    } catch (e, stackTrace) {
      debugPrint('CartService.addToCart - Error: $e');
      debugPrint('CartService.addToCart - Stack trace: $stackTrace');
      if (e is FormatException) {
        throw Exception('Response tidak valid: ${e.message}');
      }
      rethrow;
    }
  }

  static Future<CartItem> updateCart(int id, int quantity) async {
    debugPrint('CartService.updateCart - Starting...');
    debugPrint('CartService.updateCart - id: $id, quantity: $quantity');
    
    final token = await getToken();
    if (token == null) {
      debugPrint('CartService.updateCart - Token not found');
      throw Exception('Token tidak ditemukan');
    }

    try {
      final requestBody = {'quantity': quantity};
      debugPrint('CartService.updateCart - Request body: $requestBody');

      final res = await http.put(
        Uri.parse('$baseUrl${AppConstants.cartEndpoint}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      debugPrint('CartService.updateCart - Status code: ${res.statusCode}');
      debugPrint('CartService.updateCart - Response body: ${res.body}');

      if (res.statusCode == 401) {
        throw Exception('Token tidak valid atau expired');
      }

      if (res.statusCode != 200) {
        throw Exception('Gagal update keranjang: ${res.statusCode}');
      }

      final data = json.decode(res.body);
      debugPrint('CartService.updateCart - Parsed data: $data');
      
      if (data['status'] == true) {
        try {
          final cartItem = CartItem.fromJson(data['data']);
          debugPrint('CartService.updateCart - Success, item ID: ${cartItem.id}');
          return cartItem;
        } catch (e, stackTrace) {
          debugPrint('CartService.updateCart - Error parsing response: $e');
          debugPrint('CartService.updateCart - Response data: ${data['data']}');
          debugPrint('CartService.updateCart - Stack trace: $stackTrace');
          rethrow;
        }
      } else {
        throw Exception(data['message'] ?? 'Gagal update keranjang');
      }
    } catch (e, stackTrace) {
      debugPrint('CartService.updateCart - Error: $e');
      debugPrint('CartService.updateCart - Stack trace: $stackTrace');
      if (e is FormatException) {
        throw Exception('Response tidak valid: ${e.message}');
      }
      rethrow;
    }
  }

  static Future<void> deleteCartItem(int id) async {
    debugPrint('CartService.deleteCartItem - Starting...');
    debugPrint('CartService.deleteCartItem - id: $id');
    
    final token = await getToken();
    if (token == null) {
      debugPrint('CartService.deleteCartItem - Token not found');
      throw Exception('Token tidak ditemukan');
    }

    try {
      final res = await http.delete(
        Uri.parse('$baseUrl${AppConstants.cartEndpoint}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('CartService.deleteCartItem - Status code: ${res.statusCode}');
      debugPrint('CartService.deleteCartItem - Response body: ${res.body}');

      if (res.statusCode == 401) {
        throw Exception('Token tidak valid atau expired');
      }

      if (res.statusCode != 200) {
        throw Exception('Gagal hapus item: ${res.statusCode}');
      }

      final data = json.decode(res.body);
      debugPrint('CartService.deleteCartItem - Parsed data: $data');
      
      if (data['status'] != true) {
        throw Exception(data['message'] ?? 'Gagal hapus item');
      }
      
      debugPrint('CartService.deleteCartItem - Success');
    } catch (e, stackTrace) {
      debugPrint('CartService.deleteCartItem - Error: $e');
      debugPrint('CartService.deleteCartItem - Stack trace: $stackTrace');
      if (e is FormatException) {
        throw Exception('Response tidak valid: ${e.message}');
      }
      rethrow;
    }
  }

  static Future<void> clearCart() async {
    debugPrint('CartService.clearCart - Starting...');
    
    final token = await getToken();
    if (token == null) {
      debugPrint('CartService.clearCart - Token not found');
      throw Exception('Token tidak ditemukan');
    }

    try {
      final res = await http.delete(
        Uri.parse('$baseUrl${AppConstants.cartEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('CartService.clearCart - Status code: ${res.statusCode}');
      debugPrint('CartService.clearCart - Response body: ${res.body}');

      if (res.statusCode == 401) {
        throw Exception('Token tidak valid atau expired');
      }

      if (res.statusCode != 200) {
        throw Exception('Gagal kosongkan keranjang: ${res.statusCode}');
      }

      final data = json.decode(res.body);
      debugPrint('CartService.clearCart - Parsed data: $data');
      
      if (data['status'] != true) {
        throw Exception(data['message'] ?? 'Gagal kosongkan keranjang');
      }
      
      debugPrint('CartService.clearCart - Success');
    } catch (e, stackTrace) {
      debugPrint('CartService.clearCart - Error: $e');
      debugPrint('CartService.clearCart - Stack trace: $stackTrace');
      if (e is FormatException) {
        throw Exception('Response tidak valid: ${e.message}');
      }
      rethrow;
    }
  }
} 