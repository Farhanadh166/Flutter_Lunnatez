import 'package:flutter/foundation.dart';
import '../../../core/constants.dart';

class Category {
  final int id;
  final String nama;
  final String? icon;
  final String? deskripsi;

  Category({
    required this.id,
    required this.nama,
    this.icon,
    this.deskripsi,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('Category.fromJson - Input JSON: $json');
      
      final id = json['id'] ?? 0;
      debugPrint('Category.fromJson - Parsed ID: $id (type: ${id.runtimeType})');
      
      return Category(
        id: id,
        nama: json['nama'] ?? '',
        icon: json['icon'],
        deskripsi: json['deskripsi'],
      );
    } catch (e, stackTrace) {
      debugPrint('Category.fromJson - Error: $e');
      debugPrint('Category.fromJson - Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'icon': icon,
      'deskripsi': deskripsi,
    };
  }

  // Get icon URL
  String? get iconUrl {
    if (icon == null || icon!.isEmpty) {
      return null;
    }
    return '${AppConstants.baseUrl.replaceAll('/api', '')}/storage/$icon';
  }
} 