import 'package:flutter/foundation.dart';

class BankInfo {
  final int id;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String? logo;
  final bool isActive;

  BankInfo({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    this.logo,
    required this.isActive,
  });

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('BankInfo.fromJson - Input JSON: $json');
      
      final id = json['id'] ?? 0;
      debugPrint('BankInfo.fromJson - Parsed ID: $id (type: ${id.runtimeType})');
      
      return BankInfo(
        id: id,
        bankName: json['bank_name'] ?? '',
        accountNumber: json['account_number'] ?? '',
        accountName: json['account_name'] ?? '',
        logo: json['logo'],
        isActive: json['is_active'] ?? false,
      );
    } catch (e, stackTrace) {
      debugPrint('BankInfo.fromJson - Error: $e');
      debugPrint('BankInfo.fromJson - Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_name': accountName,
      'logo': logo,
      'is_active': isActive,
    };
  }
} 