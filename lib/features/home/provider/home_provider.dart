import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import '../../product/data/product_model.dart';
import '../../product/data/category_model.dart';
import '../../product/data/product_service.dart';

class HomeProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  String _error = '';
  String _searchQuery = '';
  int? _selectedCategoryId;

  // Getters
  List<Product> get products => _products;
  List<Category> get categories => _categories;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
  String get error => _error;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;

  // Initialize data
  Future<void> initializeData() async {
    foundation.debugPrint('HomeProvider.initializeData - Starting...');
    await Future.wait([
      loadCategories(),
      loadProducts(),
    ]);
    foundation.debugPrint('HomeProvider.initializeData - Completed');
  }

  // Load products
  Future<void> loadProducts() async {
    foundation.debugPrint('HomeProvider.loadProducts - Starting...');
    _setLoading(true);
    _setError('');
    
    try {
      final products = await ProductService.getProducts();
      foundation.debugPrint('HomeProvider.loadProducts - Loaded ${products.length} products');
      _products = products;
      _applyFilters();
    } catch (e, stackTrace) {
      foundation.debugPrint('HomeProvider.loadProducts - Error: $e');
      foundation.debugPrint('HomeProvider.loadProducts - Stack trace: $stackTrace');
      _setError('Gagal memuat produk: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    foundation.debugPrint('HomeProvider.loadCategories - Starting...');
    _setLoadingCategories(true);
    
    try {
      final categories = await ProductService.getCategories();
      foundation.debugPrint('HomeProvider.loadCategories - Loaded ${categories.length} categories');
      _categories = categories;
    } catch (e, stackTrace) {
      foundation.debugPrint('HomeProvider.loadCategories - Error: $e');
      foundation.debugPrint('HomeProvider.loadCategories - Stack trace: $stackTrace');
    } finally {
      _setLoadingCategories(false);
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    foundation.debugPrint('HomeProvider.searchProducts - Starting with query: $query');
    _setSearchQuery(query);
    
    if (query.isEmpty) {
      foundation.debugPrint('HomeProvider.searchProducts - Query empty, applying filters');
      _applyFilters();
      return;
    }

    _setLoading(true);
    _setError('');
    
    try {
      final products = await ProductService.searchProducts(query);
      foundation.debugPrint('HomeProvider.searchProducts - Found ${products.length} products');
      _filteredProducts = products;
    } catch (e, stackTrace) {
      foundation.debugPrint('HomeProvider.searchProducts - Error: $e');
      foundation.debugPrint('HomeProvider.searchProducts - Stack trace: $stackTrace');
      _setError('Gagal mencari produk: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Filter by category
  Future<void> filterByCategory(int? categoryId) async {
    foundation.debugPrint('HomeProvider.filterByCategory - Starting with categoryId: $categoryId');
    _setSelectedCategoryId(categoryId);
    
    if (categoryId == null) {
      foundation.debugPrint('HomeProvider.filterByCategory - CategoryId null, applying filters');
      _applyFilters();
      return;
    }

    _setLoading(true);
    _setError('');
    
    try {
      final products = await ProductService.getProductsByCategory(categoryId);
      foundation.debugPrint('HomeProvider.filterByCategory - Found ${products.length} products for category $categoryId');
      _filteredProducts = products;
    } catch (e, stackTrace) {
      foundation.debugPrint('HomeProvider.filterByCategory - Error: $e');
      foundation.debugPrint('HomeProvider.filterByCategory - Stack trace: $stackTrace');
      _setError('Gagal memfilter produk: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Apply filters
  void _applyFilters() {
    foundation.debugPrint('HomeProvider._applyFilters - Starting...');
    foundation.debugPrint('HomeProvider._applyFilters - searchQuery: $_searchQuery, selectedCategoryId: $_selectedCategoryId');
    
    if (_searchQuery.isEmpty && _selectedCategoryId == null) {
      foundation.debugPrint('HomeProvider._applyFilters - No filters, using all products');
      _filteredProducts = _products;
    } else {
      foundation.debugPrint('HomeProvider._applyFilters - Applying filters to ${_products.length} products');
      _filteredProducts = _products.where((product) {
        bool matchesSearch = _searchQuery.isEmpty || 
            product.nama.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesCategory = _selectedCategoryId == null || 
            product.kategoriId == _selectedCategoryId;
        return matchesSearch && matchesCategory;
      }).toList();
      foundation.debugPrint('HomeProvider._applyFilters - Filtered to ${_filteredProducts.length} products');
    }
  }

  // Refresh data
  Future<void> refresh() async {
    foundation.debugPrint('HomeProvider.refresh - Starting...');
    await initializeData();
  }

  // Clear search
  void clearSearch() {
    foundation.debugPrint('HomeProvider.clearSearch - Clearing search query');
    _setSearchQuery('');
    _applyFilters();
  }

  // Clear category filter
  void clearCategoryFilter() {
    foundation.debugPrint('HomeProvider.clearCategoryFilter - Clearing category filter');
    _setSelectedCategoryId(null);
    _applyFilters();
  }

  // Set filtered products (untuk filter frontend)
  void setFilteredProducts(List<Product> products) {
    _filteredProducts = products;
    notifyListeners();
  }

  // Private setters
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingCategories(bool loading) {
    _isLoadingCategories = loading;
    notifyListeners();
  }

  void _setError(String error) {
    foundation.debugPrint('HomeProvider._setError - Error: $error');
    _error = error;
    notifyListeners();
  }

  void _setSearchQuery(String query) {
    foundation.debugPrint('HomeProvider._setSearchQuery - Query: $query');
    _searchQuery = query;
    notifyListeners();
  }

  void _setSelectedCategoryId(int? categoryId) {
    foundation.debugPrint('HomeProvider._setSelectedCategoryId - CategoryId: $categoryId');
    _selectedCategoryId = categoryId;
    notifyListeners();
  }
} 