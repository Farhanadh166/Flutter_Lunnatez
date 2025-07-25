import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../data/cart_item.dart';
import '../data/cart_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> items = [];
  bool isLoading = false;
  String? error;
  int totalItems = 0;
  int totalAmount = 0;
  Set<int> loadingItemIds = {}; // id item yang sedang loading

  Future<void> fetchCart() async {
    debugPrint('CartProvider.fetchCart - Starting...');
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      final result = await CartService.fetchCart();
      debugPrint('CartProvider.fetchCart - API result: $result');
      
      items = result['items'] as List<CartItem>;
      debugPrint('CartProvider.fetchCart - Items count: ${items.length}');
      
      // Gunakan summary dari API jika tersedia, jika tidak hitung manual
      final summary = result['summary'] as Map<String, dynamic>;
      debugPrint('CartProvider.fetchCart - Summary: $summary');
      
      totalItems = summary['total_items'] ?? items.fold(0, (sum, e) => sum + e.quantity);
      totalAmount = summary['total_amount'] ?? items.fold(0, (sum, e) => sum + e.totalHarga);
      
      debugPrint('CartProvider.fetchCart - Total items: $totalItems, Total amount: $totalAmount');
      error = null;
    } catch (e, stackTrace) {
      debugPrint('CartProvider.fetchCart - Error: $e');
      debugPrint('CartProvider.fetchCart - Stack trace: $stackTrace');
      error = e.toString();
      items = [];
      totalItems = 0;
      totalAmount = 0;
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(int produkId, int quantity) async {
    loadingItemIds.add(produkId);
    notifyListeners();
    debugPrint('CartProvider.addToCart - produkId: $produkId, quantity: $quantity');
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      await CartService.addToCart(produkId, quantity);
      debugPrint('CartProvider.addToCart - Success, refreshing cart...');
      await fetchCart(); // Refresh cart data
    } catch (e, stackTrace) {
      debugPrint('CartProvider.addToCart - Error: $e');
      debugPrint('CartProvider.addToCart - Stack trace: $stackTrace');
      error = e.toString();
    }
    
    loadingItemIds.remove(produkId);
    notifyListeners();
  }

  Future<void> updateCart(int id, int quantity) async {
    loadingItemIds.add(id);
    // Update lokal dulu (optimistic)
    final idx = items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final old = items[idx];
      items[idx] = CartItem(
        id: old.id,
        keranjangId: old.keranjangId,
        produkId: old.produkId,
        quantity: quantity,
        totalHarga: old.totalHarga, // totalHarga bisa diupdate setelah fetchCart
        createdAt: old.createdAt,
        updatedAt: old.updatedAt,
        produk: old.produk,
      );
      notifyListeners();
    }
    debugPrint('CartProvider.updateCart - id: $id, quantity: $quantity');
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      await CartService.updateCart(id, quantity);
      debugPrint('CartProvider.updateCart - Success, refreshing cart...');
      await fetchCart(); // Refresh cart data
    } catch (e, stackTrace) {
      debugPrint('CartProvider.updateCart - Error: $e');
      debugPrint('CartProvider.updateCart - Stack trace: $stackTrace');
      error = e.toString();
    }
    
    loadingItemIds.remove(id);
    notifyListeners();
  }

  Future<void> deleteCartItem(int id) async {
    loadingItemIds.add(id);
    // Hapus lokal dulu (optimistic)
    items.removeWhere((e) => e.id == id);
    notifyListeners();
    debugPrint('CartProvider.deleteCartItem - id: $id');
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      await CartService.deleteCartItem(id);
      debugPrint('CartProvider.deleteCartItem - Success, refreshing cart...');
      await fetchCart(); // Refresh cart data
    } catch (e, stackTrace) {
      debugPrint('CartProvider.deleteCartItem - Error: $e');
      debugPrint('CartProvider.deleteCartItem - Stack trace: $stackTrace');
      error = e.toString();
    }
    
    loadingItemIds.remove(id);
    notifyListeners();
  }

  Future<void> clearCart() async {
    debugPrint('CartProvider.clearCart - Starting...');
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      await CartService.clearCart();
      debugPrint('CartProvider.clearCart - Success, refreshing cart...');
      await fetchCart(); // Refresh cart data
    } catch (e, stackTrace) {
      debugPrint('CartProvider.clearCart - Error: $e');
      debugPrint('CartProvider.clearCart - Stack trace: $stackTrace');
      error = e.toString();
    }
    
    isLoading = false;
    notifyListeners();
  }

  // Helper method untuk format total amount
  String get formattedTotalAmount {
    return 'Rp ${totalAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    )}';
  }

  // Helper method untuk cek apakah cart kosong
  bool get isEmpty => items.isEmpty;

  // Helper method untuk mendapatkan jumlah item unik
  int get uniqueItemsCount => items.length;

  // Reset state keranjang (dipanggil saat logout)
  void clearState() {
    debugPrint('CartProvider.clearState - Clearing all state');
    items = [];
    totalItems = 0;
    totalAmount = 0;
    error = null;
    isLoading = false;
    loadingItemIds.clear();
    notifyListeners();
  }
} 