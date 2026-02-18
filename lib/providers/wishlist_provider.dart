import 'package:flutter/material.dart';
import 'package:aivo/utils/app_logger.dart';
import '../models/wishlist.dart';
import 'package:aivo/services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();

  List<Wishlist> _wishlist = [];
  Set<String> _wishlistProductIds = {};
  bool _isLoading = false;
  int _wishlistCount = 0;

  // Getters
  List<Wishlist> get wishlist => _wishlist;
  Set<String> get wishlistProductIds => _wishlistProductIds;
  bool get isLoading => _isLoading;
  int get wishlistCount => _wishlistCount;

  /// Check if product is in wishlist
  bool isInWishlist(String productId) => _wishlistProductIds.contains(productId);

  /// Fetch user's wishlist
  Future<void> fetchWishlist({required String userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _wishlist = await _wishlistService.getUserWishlist(userId: userId, limit: 100);
      _wishlistProductIds = {for (var item in _wishlist) item.productId};
      _wishlistCount = _wishlist.length;
    } catch (e) {
      AppLogger.error('Error fetching wishlist: $e', tag: 'WishlistProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add product to wishlist
  Future<bool> addToWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
      final success = await _wishlistService.addToWishlist(
        userId: userId,
        productId: productId,
      );

      if (success) {
        _wishlistProductIds.add(productId);
        _wishlistCount++;
        notifyListeners();
      }

      return success;
    } catch (e) {
      AppLogger.error('Error adding to wishlist: $e', tag: 'WishlistProvider');
      return false;
    }
  }

  /// Remove product from wishlist
  Future<bool> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
      final success = await _wishlistService.removeFromWishlist(
        userId: userId,
        productId: productId,
      );

      if (success) {
        _wishlistProductIds.remove(productId);
        _wishlist.removeWhere((item) => item.productId == productId);
        _wishlistCount--;
        notifyListeners();
      }

      return success;
    } catch (e) {
      AppLogger.error('Error removing from wishlist: $e', tag: 'WishlistProvider');
      return false;
    }
  }

  /// Toggle wishlist (add/remove)
  Future<bool> toggleWishlist({
    required String userId,
    required String productId,
  }) async {
    if (isInWishlist(productId)) {
      return removeFromWishlist(userId: userId, productId: productId);
    } else {
      return addToWishlist(userId: userId, productId: productId);
    }
  }

  /// Clear entire wishlist
  Future<bool> clearWishlist({required String userId}) async {
    try {
      final success = await _wishlistService.clearWishlist(userId: userId);
      if (success) {
        _wishlist.clear();
        _wishlistProductIds.clear();
        _wishlistCount = 0;
        notifyListeners();
      }
      return success;
    } catch (e) {
      AppLogger.error('Error clearing wishlist: $e', tag: 'WishlistProvider');
      return false;
    }
  }
}
