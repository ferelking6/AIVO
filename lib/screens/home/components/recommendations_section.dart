import 'package:flutter/material.dart';
import 'package:aivo/services/recommendation_service_free.dart';
import 'package:aivo/utils/app_logger.dart';
import 'package:aivo/components/recommendation_card.dart';
import 'package:aivo/components/skeleton_loaders.dart';
import 'package:aivo/screens/details/details_screen.dart';
import 'package:aivo/models/Product.dart';

class RecommendationsSection extends StatefulWidget {
  final String? userId;
  final String country;
  final String? city;
  final String sectionTitle;

  const RecommendationsSection({
    super.key,
    this.userId,
    this.country = 'US',
    this.city,
    required this.sectionTitle,
  });

  @override
  State<RecommendationsSection> createState() =>
      _RecommendationsSectionState();
}

class _RecommendationsSectionState extends State<RecommendationsSection> {
  final _recoService = RecommendationServiceFree();
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendations = await _recoService.getHomeRecommendations(
        userId: widget.userId,
        country: widget.country,
        city: widget.city,
        limit: 10,
      );

      if (mounted) {
        setState(() {
          // Get first section from recommendations
          final rawData = recommendations[widget.sectionTitle.toLowerCase().replaceAll(' ', '_')] ?? [];
          _recommendations = (rawData as List).cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      AppLogger.error('Error loading recommendations: $e', tag: 'RecommendationsSection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            widget.sectionTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          SizedBox(
            height: 260,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  ...List.generate(4, (_) => const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SkeletonCard(
                      width: 160,
                      height: 240,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  )),
                ],
              ),
            ),
          )
        else if (_recommendations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'No recommendations available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 20),
                ..._recommendations.map((rec) {
                  final product = Product(
                    id: int.tryParse(rec['product_id'].toString()) ?? 0,
                    title: rec['title'] ?? 'Product',
                    price: double.tryParse(rec['price'].toString()) ?? 0.0,
                    description: '',
                    images: [rec['image_url'] ?? ''],
                    colors: [],
                    isFavourite: false,
                    isPopular: false,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: RecommendationCard(
                      productId: rec['product_id'],
                      title: rec['title'] ?? 'Product',
                      subTitle: rec['brand'] ?? 'Brand',
                      brand: rec['brand'] ?? 'Brand',
                      price: double.tryParse(rec['price'].toString()) ?? 0.0,
                      imageUrl: rec['image_url'] ?? '',
                      score: rec['score'] != null
                          ? double.tryParse(rec['score'].toString())
                          : null,
                      reason: rec['reason'],
                      onPress: () {
                        Navigator.pushNamed(
                          context,
                          DetailsScreen.routeName,
                          arguments: ProductDetailsArguments(product: product),
                        );
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(width: 20),
              ],
            ),
          ),
      ],
    );
  }
}
