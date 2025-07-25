import 'dart:io';
import 'package:flutter/material.dart';
import '../data/complaint_model.dart';
import '../data/complaint_service.dart';

class ComplaintProvider extends ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();
  
  List<Complaint> _complaints = [];
  List<Complaint> _allComplaints = []; // Semua complaint tanpa filter
  Complaint? _selectedComplaint;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<Complaint> get complaints => _complaints;
  List<Complaint> get allComplaints => _allComplaints;
  List<Complaint> get filteredComplaints {
    if (_searchQuery.isEmpty) {
      return _complaints;
    }
    return _complaints.where((complaint) {
      return complaint.reason.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             complaint.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             complaint.status.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  Complaint? get selectedComplaint => _selectedComplaint;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Set search query
  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set submitting state
  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }

  // Submit complaint baru
  Future<bool> submitComplaint({
    required int orderId,
    required String reason,
    required String description,
    File? photo,
  }) async {
    // Mencegah multiple submit
    if (_isSubmitting) {
      print('Submit blocked at provider level: already submitting');
      return false;
    }

    try {
      _setSubmitting(true);
      clearError();

      print('Provider: Starting complaint submission...');

      await _complaintService.submitComplaint(
        orderId: orderId,
        reason: reason,
        description: description,
        photo: photo,
      );

      print('Provider: Complaint submitted successfully, refreshing data...');

      // Refresh data dari server untuk menghindari duplikat
      await getComplaints(orderId);
      
      _setSubmitting(false);
      return true;
    } catch (e) {
      print('Provider: Complaint submission error: $e');
      _setError(e.toString());
      return false;
    }
  }

  // Get complaints per order
  Future<bool> getComplaints(int orderId) async {
    try {
      _setLoading(true);
      clearError();

      final complaints = await _complaintService.getComplaints(orderId);
      
      // Deduplikasi berdasarkan ID untuk menghindari data duplikat
      final Map<int, Complaint> uniqueComplaints = {};
      for (final complaint in complaints) {
        uniqueComplaints[complaint.id] = complaint;
      }
      
      _allComplaints = uniqueComplaints.values.toList();
      _complaints = _allComplaints; // Set complaints ke semua data
      
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Get detail complaint
  Future<bool> getComplaintDetail(int complaintId) async {
    try {
      _setLoading(true);
      clearError();

      final complaint = await _complaintService.getComplaintDetail(complaintId);
      _selectedComplaint = complaint;
      
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update complaint status (Admin only)
  Future<bool> updateComplaintStatus({
    required int complaintId,
    required String status,
    String? response,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final updatedComplaint = await _complaintService.updateComplaintStatus(
        complaintId: complaintId,
        status: status,
        response: response,
      );

      // Update in list
      final index = _complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        _complaints[index] = updatedComplaint;
        _allComplaints[index] = updatedComplaint; // Update _allComplaints
      }

      // Update selected complaint if it's the same
      if (_selectedComplaint?.id == complaintId) {
        _selectedComplaint = updatedComplaint;
      }

      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Clear selected complaint
  void clearSelectedComplaint() {
    _selectedComplaint = null;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _complaints = [];
    _allComplaints = [];
    _selectedComplaint = null;
    _error = null;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }
} 