class NotificationPreferences {
  final String userId;
  final bool priceDropAlerts;
  final bool backInStockAlerts;
  final bool wishlistAlerts;
  final bool dealsAndPromotions;
  final bool newArrivals;
  final bool personalizedRecommendations;
  final bool orderUpdates;

  NotificationPreferences({
    required this.userId,
    required this.priceDropAlerts,
    required this.backInStockAlerts,
    required this.wishlistAlerts,
    required this.dealsAndPromotions,
    required this.newArrivals,
    required this.personalizedRecommendations,
    required this.orderUpdates,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      userId: json['user_id'],
      priceDropAlerts: json['price_drop_alerts'] ?? true,
      backInStockAlerts: json['back_in_stock_alerts'] ?? true,
      wishlistAlerts: json['wishlist_alerts'] ?? true,
      dealsAndPromotions: json['deals_and_promotions'] ?? true,
      newArrivals: json['new_arrivals'] ?? true,
      personalizedRecommendations: json['personalized_recommendations'] ?? true,
      orderUpdates: json['order_updates'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'price_drop_alerts': priceDropAlerts,
    'back_in_stock_alerts': backInStockAlerts,
    'wishlist_alerts': wishlistAlerts,
    'deals_and_promotions': dealsAndPromotions,
    'new_arrivals': newArrivals,
    'personalized_recommendations': personalizedRecommendations,
    'order_updates': orderUpdates,
  };
}
