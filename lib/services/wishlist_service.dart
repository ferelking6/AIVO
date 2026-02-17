import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aivo/utils/app_logger.dart';
import '../models/wishlist.dart'';

class WishlistService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Add product to wishlist
  Future<bool> addToWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
      await _supabase.from('wishlists').insert({
        'user_id': userId,
        'product_id': productId,
        'added_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      AppLogger.error('Error adding to wishlist: $e', tag: 'WishlistService');
      return false;
    }
  }

  /// Remove product from wishlist
  Future<bool> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
      await _supabase
          .from('wishlists')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
      return true;
    } catch (e) {
      AppLogger.error('Error removing from wishlist: $e', tag: 'WishlistService');
      return false;
    }
  }

  /// Check if product is in wishlist
  Future<bool> isInWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
      final response = await _supabase
          .from('wishlists')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      AppLogger.error('Error checking wishlist: $e', tag: 'WishlistService');
      return false;
    }
  }

  /// Get user's wishlist
  Future<List<Wishlist>> getUserWishlist({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('wishlists')
          .select('*, products(*)')
          .eq('user_id', userId)
          .order('added_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) => Wishlist.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching wishlist: $e', tag: 'WishlistService');
      return [];
    }
  }

  /// Get wishlist count for user
  Future<int> getWishlistCount({required String userId}) async {
    try {
      final response = await _supabase
          .from('wishlists')
          .select('id')
          .eq('user_id', userId);

      return response.length;
    } catch (e) {
      AppLogger.error('Error fetching wishlist count: $e', tag: 'WishlistService');
      return 0;
    }
  }

  /// Clear entire wishlist
  Future<bool> clearWishlist({required String userId}) async {
    try {
      await _supabase.from('wishlists').delete().eq('user_id', userId);
      return true;
    } catch (e) {
      AppLogger.error('Error clearing wishlist: $e', tag: 'WishlistService');
      return false;
    }
  }

  /// Export wishlist (for sharing)
  Future<List<Map<String, dynamic>>> exportWishlist({required String userId}) async {
    try {
      final wishlist = await getUserWishlist(userId: userId, limit: 1000);
      return wishlist
          .map((w) {
            final product = w.product;
            final addedAt = w.addedAt;
            return {
              'product_id': w.productId,
              'product_title': product?.title ?? '',
              'product_price': product?.price ?? 0,
              'product_image': product?.image ?? '',
              'added_at': addedAt.toIso8601String(),
            };
          })
          .toList();
    } catch (e) {
      AppLogger.error('Error exporting wishlist: $e', tag: 'WishlistService');
      return [];
    }
  }
}
