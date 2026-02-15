import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aivo/models/NotificationPreferences.dart';

class NotificationPreferencesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get notification preferences for user
  Future<NotificationPreferences?> getPreferences({required String userId}) async {
    try {
      final response = await _supabase.rpc(
        'get_notification_preferences',
        params: {
          'p_user_id': userId,
        },
      ) as List;

      if (response.isEmpty) return null;
      return NotificationPreferences.fromJson(response[0]);
    } catch (e) {
      print('Error fetching notification preferences: $e');
      return null;
    }
  }

  /// Update notification preferences
  Future<bool> updatePreferences({
    required String userId,
    bool? priceDropAlerts,
    bool? backInStockAlerts,
    bool? wishlistAlerts,
    bool? dealsAndPromotions,
    bool? newArrivals,
    bool? personalizedRecommendations,
    bool? orderUpdates,
  }) async {
    try {
      await _supabase.rpc(
        'upsert_notification_preferences',
        params: {
          'p_user_id': userId,
          'p_price_drop_alerts': priceDropAlerts ?? true,
          'p_back_in_stock_alerts': backInStockAlerts ?? true,
          'p_wishlist_alerts': wishlistAlerts ?? true,
          'p_deals_and_promotions': dealsAndPromotions ?? true,
          'p_new_arrivals': newArrivals ?? true,
          'p_personalized_recommendations': personalizedRecommendations ?? true,
          'p_order_updates': orderUpdates ?? true,
        },
      );
      return true;
    } catch (e) {
      print('Error updating notification preferences: $e');
      return false;
    }
  }

  /// Enable all notifications
  Future<bool> enableAllNotifications({required String userId}) async {
    return updatePreferences(
      userId: userId,
      priceDropAlerts: true,
      backInStockAlerts: true,
      wishlistAlerts: true,
      dealsAndPromotions: true,
      newArrivals: true,
      personalizedRecommendations: true,
      orderUpdates: true,
    );
  }

  /// Disable all notifications
  Future<bool> disableAllNotifications({required String userId}) async {
    return updatePreferences(
      userId: userId,
      priceDropAlerts: false,
      backInStockAlerts: false,
      wishlistAlerts: false,
      dealsAndPromotions: false,
      newArrivals: false,
      personalizedRecommendations: false,
      orderUpdates: false,
    );
  }
}
