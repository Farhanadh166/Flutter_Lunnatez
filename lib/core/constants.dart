import 'package:flutter/material.dart';

class AppConstants {
  static const String baseUrl = 'http://10.200.207.73/Project_Akhir_Kelompok/public';
  // API Endpoints
  static const String loginEndpoint = '/api/login';
  static const String registerEndpoint = '/api/register';
  static const String productsEndpoint = '/api/products';
  static const String categoriesEndpoint = '/api/categories';
  static const String cartEndpoint = '/api/cart';
  static const String ordersEndpoint = '/api/orders';
  static const String paymentMethodsEndpoint = '/api/payment/methods';
  static const String bankInfoEndpoint = '/api/payment/bank-info';
  static const String uploadProofEndpoint = '/api/payment/upload-proof';
  static const String paymentStatusEndpoint = '/api/payment/status';
}

class AppColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryPurple = Color(0xFF673AB7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);
  static const Color black = Color(0xFF000000);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color lightPurple = Color(0xFFE8EAF6);
} 