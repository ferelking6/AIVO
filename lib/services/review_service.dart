import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aivo/utils/app_logger.dart';
import 'package:aivo/models/Review.dart';

class ReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Add a review for a product
  Future<bool> addReview({
    required String productId,
    required String userId,
    required int rating,
    required String title,
    required String comment,
    required bool verifiedPurchase,
  }) async {
    try {
      final response = await _supabase.rpc(
        'add_review',
        params: {
          'p_product_id': productId,
          'p_user_id': userId,
          'p_rating': rating,
          'p_title': title,
          'p_comment': comment,
          'p_verified_purchase': verifiedPurchase,
        },
      );
      return response[0]['success'] ?? false;
    } catch (e) {
      AppLogger.error('Error adding review: $e', tag: 'ReviewService');
      return false;
    }
  }

  /// Get reviews for a product
  Future<List<Review>> getProductReviews({
    required String productId,
    int? ratingFilter,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_product_reviews',
        params: {
          'p_product_id': productId,
          'p_rating_filter': ratingFilter,
          'p_limit': limit,
          'p_offset': offset,
        },
      ) as List;

      return response.map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching reviews: $e', tag: 'ReviewService');
      return [];
    }
  }

  /// Get rating summary for a product
  Future<ReviewSummary?> getProductRatingSummary(String productId) async {
    try {
      final response = await _supabase
          .from('product_ratings_summary')
          .select()
          .eq('product_id', productId)
          .single();

      return ReviewSummary.fromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching rating summary: $e', tag: 'ReviewService');
      return null;
    }
  }

  /// Add review image
  Future<bool> addReviewImage({
    required String reviewId,
    required String imageUrl,
  }) async {
    try {
      await _supabase.from('review_images').insert({
        'review_id': reviewId,
        'image_url': imageUrl,
      });
      return true;
    } catch (e) {
      AppLogger.error('Error adding review image: $e', tag: 'ReviewService');
      return false;
    }
  }

  /// Mark review as helpful
  Future<bool> markReviewHelpful(String reviewId) async {
    try {
      await _supabase.rpc(
        'update_helpful_count',
        params: {
          'p_review_id': reviewId,
          'p_increment': 1,
        },
      );
      return true;
    } catch (e) {
      AppLogger.error('Error marking review helpful: $e', tag: 'ReviewService');
      return false;
    }
  }
}
