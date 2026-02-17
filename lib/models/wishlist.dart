import '../models/product.dart';

class Wishlist {
  final String id;
  final String userId;
  final String productId;
  final Product? product;
  final DateTime addedAt;
  final DateTime? notifyAt;

  Wishlist({
    required this.id,
    required this.userId,
    required this.productId,
    this.product,
    required this.addedAt,
    this.notifyAt,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      addedAt: DateTime.parse(json['added_at']),
      notifyAt: json['notify_at'] != null ? DateTime.parse(json['notify_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'product_id': productId,
    'added_at': addedAt.toIso8601String(),
    'notify_at': notifyAt?.toIso8601String(),
  };
}
