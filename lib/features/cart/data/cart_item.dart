import 'package:flutter/foundation.dart';
import '../../product/data/product_model.dart';

class CartItem {
  final int id;
  final int keranjangId;
  final int produkId;
  final int quantity;
  final int totalHarga;
  final String createdAt;
  final String updatedAt;
  final Product produk;

  CartItem({
    required this.id,
    required this.keranjangId,
    required this.produkId,
    required this.quantity,
    required this.totalHarga,
    required this.createdAt,
    required this.updatedAt,
    required this.produk,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('CartItem.fromJson - Input JSON: $json');
      
      final id = json['id'] ?? 0;
      final produkId = json['produk_id'] ?? 0;
      debugPrint('CartItem.fromJson - Parsed ID: $id, produkId: $produkId');
      
      return CartItem(
        id: id,
        keranjangId: json['keranjang_id'] ?? 0,
        produkId: produkId,
        quantity: json['quantity'] ?? 0,
        totalHarga: json['total_harga'] ?? 0,
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
        produk: Product.fromJson(json['produk'] ?? {}),
      );
    } catch (e, stackTrace) {
      debugPrint('CartItem.fromJson - Error: $e');
      debugPrint('CartItem.fromJson - Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keranjang_id': keranjangId,
      'produk_id': produkId,
      'quantity': quantity,
      'total_harga': totalHarga,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'produk': produk.toJson(),
    };
  }
} 