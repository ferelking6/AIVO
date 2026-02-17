import 'package:flutter/material.dart';
import 'package:aivo/models/notification_preferences.dart';
import 'package:aivo/services/notification_preferences_service.dart';

class NotificationPreferencesProvider extends ChangeNotifier {
  final NotificationPreferencesService _preferencesService = NotificationPreferencesService();

  NotificationPreferences? _preferences;
  bool _isLoading = false;
  String? _error;

  // Getters
  NotificationPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch notification preferences
  Future<void> fetchPreferences({required String userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _preferences = await _preferencesService.getPreferences(userId: userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update preferences
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
      final success = await _preferencesService.updatePreferences(
        userId: userId,
        priceDropAlerts: priceDropAlerts,
        backInStockAlerts: backInStockAlerts,
        wishlistAlerts: wishlistAlerts,
        dealsAndPromotions: dealsAndPromotions,
        newArrivals: newArrivals,
        personalizedRecommendations: personalizedRecommendations,
        orderUpdates: orderUpdates,
      );

      if (success) {
        // Refresh preferences
        await fetchPreferences(userId: userId);
      }

      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Enable all notifications
  Future<bool> enableAll({required String userId}) async {
    return _preferencesService.enableAllNotifications(userId: userId);
  }

  /// Disable all notifications
  Future<bool> disableAll({required String userId}) async {
    return _preferencesService.disableAllNotifications(userId: userId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
