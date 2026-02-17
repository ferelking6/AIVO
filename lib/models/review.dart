class Review {
  final String id;
  final String productId;
  final String userId;
  final int rating;
  final String? title;
  final String? comment;
  final bool verifiedPurchase;
  final int helpfulCount;
  final int unhelpfulCount;
  final DateTime createdAt;
  final List<String> images;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.title,
    this.comment,
    required this.verifiedPurchase,
    required this.helpfulCount,
    required this.unhelpfulCount,
    required this.createdAt,
    this.images = const [],
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['review_id'],
      productId: json['product_id'] ?? '',
      userId: json['user_name'] ?? '',
      rating: json['rating'],
      title: json['title'],
      comment: json['comment'],
      verifiedPurchase: json['verified_purchase'] ?? false,
      helpfulCount: json['helpful_count'] ?? 0,
      unhelpfulCount: 0,
      createdAt: DateTime.parse(json['created_at']),
      images: List<String>.from(json['images'] ?? []),
    );
  }
}

class ReviewSummary {
  final int totalReviews;
  final double averageRating;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;

  ReviewSummary({
    required this.totalReviews,
    required this.averageRating,
    required this.fiveStarCount,
    required this.fourStarCount,
    required this.threeStarCount,
    required this.twoStarCount,
    required this.oneStarCount,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      totalReviews: json['total_reviews'] ?? 0,
      averageRating: double.tryParse(json['avg_rating'].toString()) ?? 0.0,
      fiveStarCount: json['five_star_count'] ?? 0,
      fourStarCount: json['four_star_count'] ?? 0,
      threeStarCount: json['three_star_count'] ?? 0,
      twoStarCount: json['two_star_count'] ?? 0,
      oneStarCount: json['one_star_count'] ?? 0,
    );
  }
}
