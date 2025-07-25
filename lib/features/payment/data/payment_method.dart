import 'package:flutter/foundation.dart';

class PaymentMethod {
  final String id;
  final String name;
  final String code;
  final String description;
  final bool isActive;
  final String? icon;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.isActive,
    this.icon,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('PaymentMethod.fromJson - Input JSON: $json');
      
      final id = json['id']?.toString() ?? '';
      debugPrint('PaymentMethod.fromJson - Parsed ID: $id (type: ${id.runtimeType})');
      
      // Jika code kosong, gunakan id sebagai code
      final code = json['code'] ?? id;
      debugPrint('PaymentMethod.fromJson - Parsed code: $code');
      
      return PaymentMethod(
        id: id,
        name: json['name'] ?? '',
        code: code,
        description: json['description'] ?? '',
        isActive: json['is_active'] ?? false,
        icon: json['icon'],
      );
    } catch (e, stackTrace) {
      debugPrint('PaymentMethod.fromJson - Error: $e');
      debugPrint('PaymentMethod.fromJson - Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'is_active': isActive,
      'icon': icon,
    };
  }
} 