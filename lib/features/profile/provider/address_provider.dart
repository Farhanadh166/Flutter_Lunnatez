import 'package:flutter/material.dart';

class AddressProvider extends ChangeNotifier {
  List<Map<String, dynamic>> addresses = [];
  bool isLoading = false;

  Future<void> fetchAddresses() async {}
  Future<void> addAddress(Map<String, dynamic> data) async {}
  Future<void> updateAddress(String id, Map<String, dynamic> data) async {}
  Future<void> deleteAddress(String id) async {}
} 