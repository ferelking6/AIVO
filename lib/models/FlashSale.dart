class FlashSale {
  final String id;
  final String productId;
  final String productTitle;
  final String? categoryName;
  final double discountPercent;
  final double originalPrice;
  final double salePrice;
  final DateTime endsAt;
  final String timeRemaining;
  final int? maxQuantity;
  final int soldQuantity;
  final int stockAvailable;
  final String imageUrl;

  FlashSale({
    required this.id,
    required this.productId,
    required this.productTitle,
    this.categoryName,
    required this.discountPercent,
    required this.originalPrice,
    required this.salePrice,
    required this.endsAt,
    required this.timeRemaining,
    this.maxQuantity,
    required this.soldQuantity,
    required this.stockAvailable,
    required this.imageUrl,
  });

  bool get outOfStock => stockAvailable <= 0;
  bool get limitedStock => maxQuantity != null && soldQuantity >= (maxQuantity! * 0.8);
  double get percentageSold => maxQuantity != null ? (soldQuantity / maxQuantity!) * 100 : 0;

  factory FlashSale.fromJson(Map<String, dynamic> json) {
    return FlashSale(
      id: json['sale_id'],
      productId: json['product_id'],
      productTitle: json['product_title'],
      categoryName: json['category_name'],
      discountPercent: double.tryParse(json['discount_percent'].toString()) ?? 0.0,
      originalPrice: double.tryParse(json['original_price'].toString()) ?? 0.0,
      salePrice: double.tryParse(json['sale_price'].toString()) ?? 0.0,
      endsAt: DateTime.parse(json['ends_at']),
      timeRemaining: json['time_remaining'],
      maxQuantity: json['max_quantity'],
      soldQuantity: json['sold_quantity'] ?? 0,
      stockAvailable: json['stock_available'] ?? 0,
      imageUrl: json['image_url'] ?? '',
    );
  }
}
