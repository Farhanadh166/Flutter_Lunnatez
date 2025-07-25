import 'package:flutter/material.dart';
import '../../order/data/order_model.dart';
import '../../order/data/order_service.dart';

class OrderProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  int tabIndex = 0;
  String searchQuery = '';
  
  Map<String, List<Order>> groupedOrders = {
    'pending': [],
    'paid': [],
    'shipped': [],
    'completed': [],
    'cancelled': [],
  };
  
  List<Order> get filteredOrders {
    final statusKey = _tabKey(tabIndex);
    List<Order> orders = statusKey == 'all'
      ? groupedOrders.values.expand((e) => e).toList()
      : groupedOrders[statusKey] ?? [];
    if (searchQuery.isNotEmpty) {
      orders = orders.where((o) =>
        o.orderId.contains(searchQuery) ||
        o.items.any((item) => item.nama.toLowerCase().contains(searchQuery.toLowerCase()))
      ).toList();
    }
    return orders;
  }

  String _tabKey(int idx) {
    switch (idx) {
      case 1: return 'pending';
      case 2: return 'paid';
      case 3: return 'shipped';
      case 4: return 'completed';
      case 5: return 'cancelled';
      default: return 'all';
    }
  }

  Future<void> fetchOrderHistoryGrouped() async {
    print('OrderProvider.fetchOrderHistoryGrouped - Mulai fetch');
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      groupedOrders = await OrderService.getOrderHistoryGrouped();
      print('OrderProvider.fetchOrderHistoryGrouped - Orders: ' + groupedOrders.toString());
    } catch (e, stack) {
      errorMessage = e.toString();
      print('OrderProvider.fetchOrderHistoryGrouped - Error: $e');
      print('OrderProvider.fetchOrderHistoryGrouped - Stack: $stack');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setTab(int idx) {
    tabIndex = idx;
    notifyListeners();
  }

  void setSearch(String q) {
    searchQuery = q;
    notifyListeners();
  }

  Future<bool> confirmOrderReceived(String orderId) async {
    isLoading = true;
    notifyListeners();
    try {
      final result = await OrderService.confirmOrderReceived(orderId);
      await fetchOrderHistoryGrouped();
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> fetchOrderDetail(String orderId) async {
    try {
      return await OrderService.getOrderDetail(orderId);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
} 