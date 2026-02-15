import 'package:flutter/material.dart';
import 'package:aivo/models/FlashSale.dart';
import 'package:aivo/services/flash_sales_service.dart';

class FlashSalesProvider extends ChangeNotifier {
  final FlashSalesService _flashSalesService = FlashSalesService();

  List<FlashSale> _flashSales = [];
  List<FlashSale> _categorySales = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<FlashSale> get flashSales => _flashSales;
  List<FlashSale> get categorySales => _categorySales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all active flash sales
  Future<void> fetchFlashSales({int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _flashSales = await _flashSalesService.getActiveFlashSales(limit: limit);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch flash sales by category
  Future<void> fetchCategorySales({
    required String categoryId,
    int limit = 20,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categorySales = await _flashSalesService.getFlashSalesByCategory(
        categoryId: categoryId,
        limit: limit,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new flash sale (admin)
  Future<bool> createFlashSale({
    required String productId,
    required double discountPercent,
    required double originalPrice,
    required double salePrice,
    required DateTime endsAt,
    int? maxQuantity,
  }) async {
    try {
      return await _flashSalesService.createFlashSale(
        productId: productId,
        discountPercent: discountPercent,
        originalPrice: originalPrice,
        salePrice: salePrice,
        endsAt: endsAt,
        maxQuantity: maxQuantity,
      );
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
