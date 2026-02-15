import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;
  final bool showCount;
  final MainAxisAlignment alignment;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.starSize = 16,
    this.showCount = true,
    this.alignment = MainAxisAlignment.start,
  });

  List<Widget> getStars() {
    final stars = <Widget>[];
    for (int i = 0; i < 5; i++) {
      if (i < rating.floor()) {
        stars.add(Icon(
          Icons.star,
          size: starSize,
          color: Colors.amber,
        ));
      } else if (i == rating.floor() && rating % 1 != 0) {
        stars.add(Icon(
          Icons.star_half,
          size: starSize,
          color: Colors.amber,
        ));
      } else {
        stars.add(Icon(
          Icons.star_outline,
          size: starSize,
          color: Colors.grey,
        ));
      }
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        ...getStars(),
        SizedBox(width: 8),
        if (showCount)
          Text(
            '$rating (${reviewCount > 0 ? '$reviewCount reviews' : 'No reviews'})',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          )
      ],
    );
  }
}
