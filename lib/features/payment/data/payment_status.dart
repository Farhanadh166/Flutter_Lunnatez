import 'package:flutter/foundation.dart';
import '../../order/data/order_model.dart';

class PaymentStatus {
  final String orderId;
  final String status;
  final String? orderStatus;
  final String? paymentMethod;
  final int? totalAmount;
  final int? shippingCost;
  final int? subtotal;
  final Address? address;
  final List<OrderItem>? items;
  final PaymentInfo? payment;
  final String? notes;
  final DateTime? paidAt;
  final DateTime? verifiedAt;

  PaymentStatus({
    required this.orderId,
    required this.status,
    this.orderStatus,
    this.paymentMethod,
    this.totalAmount,
    this.shippingCost,
    this.subtotal,
    this.address,
    this.items,
    this.payment,
    this.notes,
    this.paidAt,
    this.verifiedAt,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('PaymentStatus.fromJson - Input JSON: $json');
      return PaymentStatus(
        orderId: json['order_id']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        orderStatus: json['order_status']?.toString(),
        paymentMethod: json['payment_method']?.toString(),
        totalAmount: json['total_amount'] is int ? json['total_amount'] : int.tryParse(json['total_amount']?.toString() ?? ''),
        shippingCost: json['shipping_cost'] is int ? json['shipping_cost'] : int.tryParse(json['shipping_cost']?.toString() ?? ''),
        subtotal: json['subtotal'] is int ? json['subtotal'] : int.tryParse(json['subtotal']?.toString() ?? ''),
        address: json['address'] != null ? Address.fromJson(json['address']) : null,
        items: (json['items'] as List?)?.map((e) => OrderItem.fromJson(e)).toList(),
        payment: json['payment'] != null ? PaymentInfo.fromJson(json['payment']) : null,
        notes: json['notes']?.toString(),
        paidAt: json['paid_at'] != null && json['paid_at'].toString().isNotEmpty ? DateTime.tryParse(json['paid_at'].toString()) : null,
        verifiedAt: json['verified_at'] != null && json['verified_at'].toString().isNotEmpty ? DateTime.tryParse(json['verified_at'].toString()) : null,
      );
    } catch (e, stackTrace) {
      debugPrint('PaymentStatus.fromJson - Error: $e');
      debugPrint('PaymentStatus.fromJson - Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'status': status,
      'payment_method': paymentMethod,
      'notes': notes,
      'paid_at': paidAt?.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';
} 