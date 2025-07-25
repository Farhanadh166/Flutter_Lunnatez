import 'package:flutter/material.dart';
import '../data/address_service.dart';

class AddressProvider extends ChangeNotifier {
  List<dynamic> addresses = [];
  bool isLoading = false;
  String? error;
  String? success;

  Future<void> fetchAddresses(String token) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      addresses = await AddressService.getAddresses(token);
      success = null;
      // Jika data berhasil diambil, clear error meskipun ada exception
      error = null;
    } catch (e) {
      // Jika error mengandung "berhasil", berarti sebenarnya sukses
      if (e.toString().contains('berhasil')) {
        error = null;
      } else {
        error = e.toString();
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> addAddress(String token, Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await AddressService.addAddress(token, data);
      await fetchAddresses(token);
      success = 'Alamat berhasil ditambah';
      return result;
    } catch (e) {
      // Jika error mengandung "berhasil", berarti sebenarnya sukses
      if (e.toString().contains('berhasil')) {
        error = null;
        await fetchAddresses(token);
        success = 'Alamat berhasil ditambah';
        return true;
      } else {
        error = e.toString();
        return false;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editAddress(String token, int id, Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await AddressService.editAddress(token, id, data);
      await fetchAddresses(token);
      success = 'Alamat berhasil diedit';
      return result;
    } catch (e) {
      // Jika error mengandung "berhasil", berarti sebenarnya sukses
      if (e.toString().contains('berhasil')) {
        error = null;
        await fetchAddresses(token);
        success = 'Alamat berhasil diedit';
        return true;
      } else {
        error = e.toString();
        return false;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(String token, int id) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await AddressService.deleteAddress(token, id);
      await fetchAddresses(token);
      success = 'Alamat berhasil dihapus';
      return result;
    } catch (e) {
      // Jika error mengandung "berhasil", berarti sebenarnya sukses
      if (e.toString().contains('berhasil')) {
        error = null;
        await fetchAddresses(token);
        success = 'Alamat berhasil dihapus';
        return true;
      } else {
        error = e.toString();
        return false;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
} 