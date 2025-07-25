import 'package:flutter/foundation.dart';

class Address {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String province;
  final String postalCode;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.province,
    required this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('Address.fromJson - Input JSON: $json');
      final id = json['id']?.toString() ?? '';
      return Address(
        id: id,
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        province: json['province']?.toString() ?? '',
        postalCode: json['postal_code']?.toString() ?? '',
      );
    } catch (e, stackTrace) {
      debugPrint('Address.fromJson - Error: $e');
      debugPrint('Address.fromJson - Stack trace: $stackTrace');
      rethrow;
    }
  }
}

class ShippingMethod {
  final String id;
  final String name;
  final int cost;
  final String? estimation;

  ShippingMethod({
    required this.id,
    required this.name,
    required this.cost,
    this.estimation,
  });

  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('ShippingMethod.fromJson - Input JSON: $json');
      
      final id = json['id']?.toString() ?? '';
      debugPrint('ShippingMethod.fromJson - Parsed ID: $id (type: ${id.runtimeType})');
      
      return ShippingMethod(
        id: id,
        name: json['name'] ?? '',
        cost: json['base_cost'] ?? 0,
        estimation: json['estimation'] ?? json['description'],
      );
    } catch (e, stackTrace) {
      debugPrint('ShippingMethod.fromJson - Error: $e');
      debugPrint('ShippingMethod.fromJson - Stack trace: $stackTrace');
      rethrow;
    }
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String code;

  PaymentMethod({required this.id, required this.name, this.code = ''});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('PaymentMethod.fromJson (OrderModel) - Input JSON: $json');
      
      final id = json['id']?.toString() ?? '';
      debugPrint('PaymentMethod.fromJson (OrderModel) - Parsed ID: $id (type: ${id.runtimeType})');
      
      return PaymentMethod(
        id: id,
        name: json['name'] ?? '',
        code: json['code'] ?? '',
      );
    } catch (e, stackTrace) {
      debugPrint('PaymentMethod.fromJson (OrderModel) - Error: $e');
      debugPrint('PaymentMethod.fromJson (OrderModel) - Stack trace: $stackTrace');
      rethrow;
    }
  }
}

class OrderItem {
  final int produkId;
  final String nama;
  final int jumlah;
  final int harga;
  final int subtotal;
  final String gambar;

  OrderItem({
    required this.produkId,
    required this.nama,
    required this.jumlah,
    required this.harga,
    required this.subtotal,
    required this.gambar,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    produkId: json['produk_id'] is int ? json['produk_id'] : int.tryParse(json['produk_id']?.toString() ?? '') ?? 0,
    nama: json['nama']?.toString() ?? '',
    jumlah: json['jumlah'] is int ? json['jumlah'] : int.tryParse(json['jumlah']?.toString() ?? '') ?? 0,
    harga: json['harga'] is int ? json['harga'] : int.tryParse(json['harga']?.toString() ?? '') ?? 0,
    subtotal: json['subtotal'] is int ? json['subtotal'] : int.tryParse(json['subtotal']?.toString() ?? '') ?? 0,
    gambar: json['gambar']?.toString() ?? '',
  );
}

class ProductShort {
  final int id;
  final String nama;
  final String gambar;

  ProductShort({required this.id, required this.nama, required this.gambar});

  factory ProductShort.fromJson(Map<String, dynamic> json) => ProductShort(
    id: json['id'] ?? 0,
    nama: json['nama'] ?? '',
    gambar: json['gambar'] ?? '',
  );
}

class PaymentInfo {
  final String status;
  final String? paymentDate;
  final String? proofUrl;

  PaymentInfo({required this.status, this.paymentDate, this.proofUrl});

  factory PaymentInfo.fromJson(Map<String, dynamic> json) => PaymentInfo(
    status: json['status']?.toString() ?? '',
    paymentDate: json['payment_date']?.toString(),
    proofUrl: json['proof_url']?.toString(),
  );
}

class Order {
  final String orderId;
  final String orderNumber; // Tambahan untuk display
  final String status;
  final String createdAt;
  final int totalAmount;
  final int shippingCost;
  final int subtotal;
  final String paymentMethod;
  final Address address;
  final List<OrderItem> items;
  final PaymentInfo? payment;

  Order({
    required this.orderId,
    required this.orderNumber, // Tambahan
    required this.status,
    required this.createdAt,
    required this.totalAmount,
    required this.shippingCost,
    required this.subtotal,
    required this.paymentMethod,
    required this.address,
    required this.items,
    this.payment,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('Order.fromJson - Starting...');
      debugPrint('Order.fromJson - Input JSON: $json');
      debugPrint('Order.fromJson - order_number: ${json['order_number']}');
      debugPrint('Order.fromJson - id: ${json['id']}');
      debugPrint('Order.fromJson - status: ${json['status']}');
      debugPrint('Order.fromJson - created_at: ${json['created_at']}');
      debugPrint('Order.fromJson - total_amount: ${json['total_amount']}');
      debugPrint('Order.fromJson - shipping_cost: ${json['shipping_cost']}');
      debugPrint('Order.fromJson - subtotal: ${json['subtotal']}');
      debugPrint('Order.fromJson - payment_method: ${json['payment_method']}');
      debugPrint('Order.fromJson - address: ${json['address']}');
      debugPrint('Order.fromJson - items: ${json['items']}');
      debugPrint('Order.fromJson - payment: ${json['payment']}');
      
      // Gunakan id numerik untuk detail pesanan, order_number untuk display
      final orderId = json['id']?.toString() ?? json['order_id']?.toString() ?? '';
      final orderNumber = json['order_number']?.toString() ?? '';
      
      debugPrint('Order.fromJson - Parsed orderId: $orderId');
      debugPrint('Order.fromJson - Parsed orderNumber: $orderNumber');
      
      final order = Order(
        orderId: orderId,
        orderNumber: orderNumber, // Tambahan
        status: json['status']?.toString() ?? '',
        createdAt: json['created_at']?.toString() ?? '',
        totalAmount: json['total_amount'] is int ? json['total_amount'] : int.tryParse(json['total_amount']?.toString() ?? '') ?? 0,
        shippingCost: json['shipping_cost'] is int ? json['shipping_cost'] : int.tryParse(json['shipping_cost']?.toString() ?? '') ?? 0,
        subtotal: json['subtotal'] is int ? json['subtotal'] : int.tryParse(json['subtotal']?.toString() ?? '') ?? 0,
        paymentMethod: json['payment_method']?.toString() ?? '',
        address: Address.fromJson(json['address'] ?? {}),
        items: (json['items'] as List? ?? []).map((e) => OrderItem.fromJson(e)).toList(),
        payment: json['payment'] != null ? PaymentInfo.fromJson(json['payment']) : null,
      );
      
      debugPrint('Order.fromJson - Order created successfully: ${order.orderId}');
      return order;
    } catch (e, stackTrace) {
      debugPrint('Order.fromJson - Error: $e');
      debugPrint('Order.fromJson - Stack trace: $stackTrace');
      rethrow;
    }
  }
}

class OrderResponse {
  final bool status;
  final String message;
  final Order? data;

  OrderResponse({required this.status, required this.message, this.data});

  factory OrderResponse.fromJson(Map<String, dynamic> json) => OrderResponse(
    status: json['status'],
    message: json['message'],
    data: json['data'] != null ? Order.fromJson(json['data']) : null,
  );
} 