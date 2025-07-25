import 'dart:convert';
import 'package:flutter/foundation.dart' as foundation;
import 'package:http/http.dart' as http;
import '../data/product_model.dart';
import '../data/category_model.dart';
import '../../../core/constants.dart';
import '../../auth/data/auth_service.dart';

class ProductService {
  // Get products
  static Future<List<Product>> getProducts() async {
    foundation.debugPrint('ProductService.getProducts - Starting...');
    try {
      final token = await AuthService.refreshTokenIfNeeded();
      foundation.debugPrint('ProductService.getProducts - Token found: ${token != null}');
      
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.productsEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      foundation.debugPrint('ProductService.getProducts - Status code: ${response.statusCode}');
      foundation.debugPrint('ProductService.getProducts - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        foundation.debugPrint('ProductService.getProducts - Parsed response: $responseData');
        
        if (responseData['status'] == true) {
          final List<dynamic> productsData = responseData['data'];
          foundation.debugPrint('ProductService.getProducts - Raw products data: $productsData');
          
          final products = productsData.map((json) {
            try {
              return Product.fromJson(json);
            } catch (e, stackTrace) {
              foundation.debugPrint('ProductService.getProducts - Error parsing product: $e');
              foundation.debugPrint('ProductService.getProducts - Product JSON: $json');
              foundation.debugPrint('ProductService.getProducts - Stack trace: $stackTrace');
              rethrow;
            }
          }).toList();
          
          foundation.debugPrint('ProductService.getProducts - Parsed ${products.length} products');
          return products;
        }
      }
      foundation.debugPrint('ProductService.getProducts - No products found or error');
      return [];
    } catch (e, stackTrace) {
      foundation.debugPrint('ProductService.getProducts - Error: $e');
      foundation.debugPrint('ProductService.getProducts - Stack trace: $stackTrace');
      return [];
    }
  }

  // Get categories
  static Future<List<Category>> getCategories() async {
    foundation.debugPrint('ProductService.getCategories - Starting...');
    try {
      final token = await AuthService.refreshTokenIfNeeded();
      foundation.debugPrint('ProductService.getCategories - Token found: ${token != null}');
      
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.categoriesEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      foundation.debugPrint('ProductService.getCategories - Status code: ${response.statusCode}');
      foundation.debugPrint('ProductService.getCategories - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        foundation.debugPrint('ProductService.getCategories - Parsed response: $responseData');
        
        if (responseData['status'] == true) {
          final List<dynamic> categoriesData = responseData['data'];
          foundation.debugPrint('ProductService.getCategories - Raw categories data: $categoriesData');
          
          final categories = categoriesData.map((json) {
            try {
              return Category.fromJson(json);
            } catch (e, stackTrace) {
              foundation.debugPrint('ProductService.getCategories - Error parsing category: $e');
              foundation.debugPrint('ProductService.getCategories - Category JSON: $json');
              foundation.debugPrint('ProductService.getCategories - Stack trace: $stackTrace');
              rethrow;
            }
          }).toList();
          
          foundation.debugPrint('ProductService.getCategories - Parsed ${categories.length} categories');
          return categories;
        }
      }
      foundation.debugPrint('ProductService.getCategories - No categories found or error');
      return [];
    } catch (e, stackTrace) {
      foundation.debugPrint('ProductService.getCategories - Error: $e');
      foundation.debugPrint('ProductService.getCategories - Stack trace: $stackTrace');
      return [];
    }
  }

  // Search products
  static Future<List<Product>> searchProducts(String query) async {
    foundation.debugPrint('ProductService.searchProducts - Starting with query: $query');
    try {
      final token = await AuthService.refreshTokenIfNeeded();
      foundation.debugPrint('ProductService.searchProducts - Token found: ${token != null}');
      
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.productsEndpoint}?search=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      foundation.debugPrint('ProductService.searchProducts - Status code: ${response.statusCode}');
      foundation.debugPrint('ProductService.searchProducts - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        foundation.debugPrint('ProductService.searchProducts - Parsed response: $responseData');
        
        if (responseData['status'] == true) {
          final List<dynamic> productsData = responseData['data'];
          foundation.debugPrint('ProductService.searchProducts - Raw products data: $productsData');
          
          final products = productsData.map((json) {
            try {
              return Product.fromJson(json);
            } catch (e, stackTrace) {
              foundation.debugPrint('ProductService.searchProducts - Error parsing product: $e');
              foundation.debugPrint('ProductService.searchProducts - Product JSON: $json');
              foundation.debugPrint('ProductService.searchProducts - Stack trace: $stackTrace');
              rethrow;
            }
          }).toList();
          
          foundation.debugPrint('ProductService.searchProducts - Parsed ${products.length} products');
          return products;
        }
      }
      foundation.debugPrint('ProductService.searchProducts - No products found or error');
      return [];
    } catch (e, stackTrace) {
      foundation.debugPrint('ProductService.searchProducts - Error: $e');
      foundation.debugPrint('ProductService.searchProducts - Stack trace: $stackTrace');
      return [];
    }
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory(int categoryId) async {
    foundation.debugPrint('ProductService.getProductsByCategory - Starting with categoryId: $categoryId');
    try {
      final token = await AuthService.refreshTokenIfNeeded();
      foundation.debugPrint('ProductService.getProductsByCategory - Token found: ${token != null}');
      
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.productsEndpoint}?category_id=$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      foundation.debugPrint('ProductService.getProductsByCategory - Status code: ${response.statusCode}');
      foundation.debugPrint('ProductService.getProductsByCategory - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        foundation.debugPrint('ProductService.getProductsByCategory - Parsed response: $responseData');
        
        if (responseData['status'] == true) {
          final List<dynamic> productsData = responseData['data'];
          foundation.debugPrint('ProductService.getProductsByCategory - Raw products data: $productsData');
          
          final products = productsData.map((json) {
            try {
              return Product.fromJson(json);
            } catch (e, stackTrace) {
              foundation.debugPrint('ProductService.getProductsByCategory - Error parsing product: $e');
              foundation.debugPrint('ProductService.getProductsByCategory - Product JSON: $json');
              foundation.debugPrint('ProductService.getProductsByCategory - Stack trace: $stackTrace');
              rethrow;
            }
          }).toList();
          
          foundation.debugPrint('ProductService.getProductsByCategory - Parsed ${products.length} products');
          return products;
        }
      }
      foundation.debugPrint('ProductService.getProductsByCategory - No products found or error');
      return [];
    } catch (e, stackTrace) {
      foundation.debugPrint('ProductService.getProductsByCategory - Error: $e');
      foundation.debugPrint('ProductService.getProductsByCategory - Stack trace: $stackTrace');
      return [];
    }
  }

  // Get product detail
  static Future<Product> getProductDetail(int id) async {
    foundation.debugPrint('ProductService.getProductDetail - Starting with id: $id');
    try {
      final token = await AuthService.refreshTokenIfNeeded();
      foundation.debugPrint('ProductService.getProductDetail - Token found:  [32m${token != null} [0m');
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/products/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      foundation.debugPrint('ProductService.getProductDetail - Status code: ${response.statusCode}');
      foundation.debugPrint('ProductService.getProductDetail - Response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          return Product.fromJson(responseData['data']);
        }
        throw Exception(responseData['message'] ?? 'Gagal mengambil detail produk');
      }
      throw Exception('Gagal mengambil detail produk: ${response.statusCode}');
    } catch (e, stackTrace) {
      foundation.debugPrint('ProductService.getProductDetail - Error: $e');
      foundation.debugPrint('ProductService.getProductDetail - Stack trace: $stackTrace');
      rethrow;
    }
  }
} 