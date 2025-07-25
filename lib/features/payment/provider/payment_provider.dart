import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../data/payment_method.dart';
import '../data/bank_info.dart';
import '../data/payment_status.dart';
import '../data/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  
  // State variables
  List<PaymentMethod> _paymentMethods = [];
  List<BankInfo> _bankInfo = [];
  PaymentStatus? _paymentStatus;
  bool _isLoading = false;
  String? _error;
  File? _selectedImage;
  String? _notes;

  // Getters
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  List<BankInfo> get bankInfo => _bankInfo;
  PaymentStatus? get paymentStatus => _paymentStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  File? get selectedImage => _selectedImage;
  String? get notes => _notes;

  // Methods
  Future<void> fetchPaymentMethods() async {
    debugPrint('PaymentProvider.fetchPaymentMethods - Starting...');
    _setLoading(true);
    _clearError();
    
    try {
      _paymentMethods = await _paymentService.getPaymentMethods();
      debugPrint('PaymentProvider.fetchPaymentMethods - Success, count: ${_paymentMethods.length}');
      debugPrint('PaymentProvider.fetchPaymentMethods - Methods: ${_paymentMethods.map((e) => '${e.id}:${e.name}').toList()}');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('PaymentProvider.fetchPaymentMethods - Error: $e');
      debugPrint('PaymentProvider.fetchPaymentMethods - Stack trace: $stackTrace');
      
      // Handle token expired error specifically
      if (e.toString().contains('Token tidak valid') || e.toString().contains('expired')) {
        _setError('Sesi Anda telah berakhir. Silakan login ulang.');
      } else {
        _setError(e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchBankInfo() async {
    debugPrint('PaymentProvider.fetchBankInfo - Starting...');
    _setLoading(true);
    _clearError();
    
    try {
      _bankInfo = await _paymentService.getBankInfo();
      debugPrint('PaymentProvider.fetchBankInfo - Success, count: ${_bankInfo.length}');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('PaymentProvider.fetchBankInfo - Error: $e');
      debugPrint('PaymentProvider.fetchBankInfo - Stack trace: $stackTrace');
      
      // Handle token expired error specifically
      if (e.toString().contains('Token tidak valid') || e.toString().contains('expired')) {
        _setError('Sesi Anda telah berakhir. Silakan login ulang.');
      } else {
        _setError(e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadProof(String orderId, {bool useSession = false}) async {
    debugPrint('PaymentProvider.uploadProof - Starting for orderId: $orderId, useSession: $useSession');
    if (_selectedImage == null) {
      debugPrint('PaymentProvider.uploadProof - No image selected');
      _setError('Pilih bukti transfer terlebih dahulu');
      return false;
    }

    _setLoading(true);
    _clearError();
    
    try {
      final success = await _paymentService.uploadProof(
        orderId: orderId,
        imageFile: _selectedImage!,
        notes: _notes,
        useSession: useSession,
      );
      
      debugPrint('PaymentProvider.uploadProof - Result: $success');
      
      if (success) {
        // Refresh payment status after successful upload
        await fetchPaymentStatus(orderId);
      }
      
      return success;
    } catch (e, stackTrace) {
      debugPrint('PaymentProvider.uploadProof - Error: $e');
      debugPrint('PaymentProvider.uploadProof - Stack trace: $stackTrace');
      
      // Handle token expired error specifically
      if (e.toString().contains('Token tidak valid') || e.toString().contains('expired')) {
        if (useSession) {
          _setError('Gagal upload. Silakan coba lagi.');
        } else {
          _setError('Sesi Anda telah berakhir. Silakan login ulang.');
        }
      } else {
        _setError(e.toString());
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Upload proof without login (public endpoint)
  Future<Map<String, dynamic>?> uploadProofWithoutLogin(String orderId) async {
    debugPrint('PaymentProvider.uploadProofWithoutLogin - Starting for orderId: $orderId');
    debugPrint('PaymentProvider.uploadProofWithoutLogin - Selected image:  [38;5;2m${_selectedImage?.path} [0m');
    debugPrint('PaymentProvider.uploadProofWithoutLogin - Notes: $_notes');
    
    if (_selectedImage == null) {
      debugPrint('PaymentProvider.uploadProofWithoutLogin - No image selected');
      _setError('Pilih bukti transfer terlebih dahulu');
      return null;
    }

    _setLoading(true);
    _clearError();
    
    try {
      debugPrint('PaymentProvider.uploadProofWithoutLogin - Calling PaymentService...');
      final response = await _paymentService.uploadProofWithoutLogin(
        orderId: orderId,
        imageFile: _selectedImage!,
        notes: _notes,
      );
      debugPrint('PaymentProvider.uploadProofWithoutLogin - Result: $response');
      if (response['status'] == true) {
        _clearError();
        debugPrint('PaymentProvider.uploadProofWithoutLogin - Upload successful');
        return response;
      } else {
        _setError(response['message'] ?? 'Gagal upload bukti transfer');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('PaymentProvider.uploadProofWithoutLogin - Error: $e');
      debugPrint('PaymentProvider.uploadProofWithoutLogin - Error type: ${e.runtimeType}');
      debugPrint('PaymentProvider.uploadProofWithoutLogin - Stack trace: $stackTrace');
      
      // Log specific error details
      if (e.toString().contains('timeout')) {
        debugPrint('PaymentProvider.uploadProofWithoutLogin - Timeout error detected');
        _setError('Koneksi timeout. Periksa internet Anda.');
      } else if (e.toString().contains('connection')) {
        debugPrint('PaymentProvider.uploadProofWithoutLogin - Connection error detected');
        _setError('Tidak dapat terhubung ke server. Periksa internet Anda.');
      } else if (e.toString().contains('404')) {
        debugPrint('PaymentProvider.uploadProofWithoutLogin - 404 error detected');
        _setError('Endpoint tidak ditemukan. Hubungi admin.');
      } else if (e.toString().contains('500')) {
        debugPrint('PaymentProvider.uploadProofWithoutLogin - 500 error detected');
        _setError('Server error. Coba lagi nanti.');
      } else if (e.toString().contains('order id is invalid')) {
        debugPrint('PaymentProvider.uploadProofWithoutLogin - Order ID invalid error detected');
        _setError('Order ID tidak valid. Pastikan order sudah dibuat dan coba lagi.');
      } else if (e.toString().contains('422')) {
        debugPrint('PaymentProvider.uploadProofWithoutLogin - 422 validation error detected');
        _setError('Data tidak valid. Periksa order ID dan file yang diupload.');
      } else {
        debugPrint('PaymentProvider.uploadProofWithoutLogin - Generic error');
        _setError('Gagal upload. Silakan coba lagi. Error: ${e.toString()}');
      }
      
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPaymentStatus(String orderId) async {
    debugPrint('PaymentProvider.fetchPaymentStatus - Starting for orderId: $orderId');
    _setLoading(true);
    _clearError();
    
    try {
      _paymentStatus = await _paymentService.getPaymentStatus(orderId);
      debugPrint('PaymentProvider.fetchPaymentStatus - Success: ${_paymentStatus?.status}');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('PaymentProvider.fetchPaymentStatus - Error: $e');
      debugPrint('PaymentProvider.fetchPaymentStatus - Stack trace: $stackTrace');
      // Handle token expired error specifically
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.replaceFirst('Exception: ', '');
      }
      if (msg.contains('Token tidak valid') || msg.contains('expired')) {
        _setError('Sesi Anda telah berakhir. Silakan login ulang.');
      } else {
        _setError(msg);
      }
    } finally {
      _setLoading(false);
    }
  }

  void setSelectedImage(File? image) {
    debugPrint('PaymentProvider.setSelectedImage - Image: ${image?.path}');
    _selectedImage = image;
    notifyListeners();
  }

  void setNotes(String? notes) {
    debugPrint('PaymentProvider.setNotes - Notes: $notes');
    _notes = notes;
    notifyListeners();
  }

  void clearSelectedImage() {
    debugPrint('PaymentProvider.clearSelectedImage - Clearing image');
    _selectedImage = null;
    notifyListeners();
  }

  void clearNotes() {
    debugPrint('PaymentProvider.clearNotes - Clearing notes');
    _notes = null;
    notifyListeners();
  }

  void clearState() {
    debugPrint('PaymentProvider.clearState - Clearing all state');
    _paymentMethods = [];
    _bankInfo = [];
    _paymentStatus = null;
    _selectedImage = null;
    _notes = null;
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    debugPrint('PaymentProvider._setError - Error: $error');
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
} 