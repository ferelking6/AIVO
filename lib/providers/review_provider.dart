import 'package:flutter/material.dart';
import 'package:aivo/models/Review.dart';
import 'package:aivo/services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  List<Review> _reviews = [];
  ReviewSummary? _ratingSummary;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Review> get reviews => _reviews;
  ReviewSummary? get ratingSummary => _ratingSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch reviews for a product
  Future<void> fetchProductReviews({
    required String productId,
    int? ratingFilter,
    int limit = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await _reviewService.getProductReviews(
        productId: productId,
        ratingFilter: ratingFilter,
        limit: limit,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch rating summary
  Future<void> fetchRatingSummary({required String productId}) async {
    try {
      _ratingSummary = await _reviewService.getProductRatingSummary(productId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Add new review
  Future<bool> addReview({
    required String productId,
    required String userId,
    required int rating,
    required String title,
    required String comment,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _reviewService.addReview(
        productId: productId,
        userId: userId,
        rating: rating,
        title: title,
        comment: comment,
        verifiedPurchase: true,
      );

      if (success) {
        // Refresh reviews
        await fetchProductReviews(productId: productId);
        await fetchRatingSummary(productId: productId);
      }

      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
