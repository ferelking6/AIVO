import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();

  List<Product> _allProducts = [];
  List<Product> _popularProducts = [];
  List<Product> _userFavorites = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get allProducts => _allProducts;
  List<Product> get popularProducts => _popularProducts;
  List<Product> get userFavorites => _userFavorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all products from Supabase
  Future<void> fetchAllProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allProducts = await _productService.fetchAllProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _allProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch popular products
  Future<void> fetchPopularProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _popularProducts = await _productService.fetchPopularProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _popularProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch user favorites
  Future<void> fetchUserFavorites() async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        _userFavorites = [];
        notifyListeners();
        return;
      }

      _userFavorites = await _productService.fetchUserFavorites(user.id);

      // Update favorite status in all products
      for (var product in _allProducts) {
        product.isFavourite = _userFavorites
            .any((fav) => fav.id == product.id);
      }
      for (var product in _popularProducts) {
        product.isFavourite = _userFavorites
            .any((fav) => fav.id == product.id);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// Toggle favorite for a product
  Future<bool> toggleFavorite(Product product) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        _error = 'User not authenticated';
        notifyListeners();
        return false;
      }

      final success = await _productService.toggleFavorite(
        product.id.toString(),
        user.id,
        product.isFavourite,
      );

      if (success) {
        product.isFavourite = !product.isFavourite;

        if (product.isFavourite) {
          if (!_userFavorites.any((p) => p.id == product.id)) {
            _userFavorites.add(product);
          }
        } else {
          _userFavorites.removeWhere((p) => p.id == product.id);
        }

        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get product by ID
  Product? getProductById(int id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
