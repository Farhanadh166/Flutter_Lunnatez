import 'package:flutter/foundation.dart';

class Product {
  final int id;
  final String nama;
  final int harga;
  final String deskripsi;
  final String gambar;
  final int kategoriId;
  final Kategori kategori;
  final int stok;

  Product({
    required this.id,
    required this.nama,
    required this.harga,
    required this.deskripsi,
    required this.gambar,
    required this.kategoriId,
    required this.kategori,
    required this.stok,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('Product.fromJson - Input JSON: $json');
      
      final id = json['id'] ?? 0;
      final kategoriId = json['kategori_id'] ?? 0;
      debugPrint('Product.fromJson - Parsed ID: $id, kategoriId: $kategoriId');
      
      return Product(
        id: id,
        nama: json['nama'] ?? '',
        harga: json['harga'] ?? 0,
        deskripsi: json['deskripsi'] ?? '',
        gambar: json['gambar'] ?? '',
        kategoriId: kategoriId,
        kategori: Kategori.fromJson(json['kategori'] ?? {}),
        stok: json['stok'] ?? 0,
      );
    } catch (e, stackTrace) {
      debugPrint('Product.fromJson - Error: $e');
      debugPrint('Product.fromJson - Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'kategori_id': kategoriId,
      'kategori': kategori.toJson(),
      'stok': stok,
    };
  }

  // Format harga ke format currency Indonesia
  String get formattedPrice {
    return 'Rp ${harga.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    )}';
  }

  // Get image URL
  String get imageUrl {
    if (gambar.isEmpty) {
      return 'https://via.placeholder.com/300x300.png?text=No+Image';
    }
    return gambar;
  }
}

class Kategori {
  final int id;
  final String nama;

  Kategori({
    required this.id,
    required this.nama,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('Kategori.fromJson - Input JSON: $json');
      
      final id = json['id'] ?? 0;
      debugPrint('Kategori.fromJson - Parsed ID: $id');
      
      return Kategori(
        id: id,
        nama: json['nama'] ?? '',
      );
    } catch (e, stackTrace) {
      debugPrint('Kategori.fromJson - Error: $e');
      debugPrint('Kategori.fromJson - Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }
} 