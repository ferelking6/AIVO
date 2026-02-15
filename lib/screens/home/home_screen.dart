import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aivo/providers/auth_provider.dart';

import 'components/categories.dart';
import 'components/discount_banner.dart';
import 'components/home_header.dart';
import 'components/popular_product.dart';
import 'components/special_offers.dart';
import 'components/recommendations_section.dart';
import 'components/flash_sales_section.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "/home";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.id;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              const HomeHeader(),
              const DiscountBanner(),
              const FlashSalesSection(),
              const SizedBox(height: 20),
              const Categories(),
              const SpecialOffers(),
              const SizedBox(height: 20),
              // Trending Products
              RecommendationsSection(
                userId: userId,
                country: 'US',
                sectionTitle: 'Trending Now',
              ),
              const SizedBox(height: 20),
              const PopularProducts(),
              const SizedBox(height: 20),
              // For You Recommendations
              RecommendationsSection(
                userId: userId,
                country: 'US',
                sectionTitle: 'For You',
              ),
              const SizedBox(height: 20),
              // New Arrivals
              RecommendationsSection(
                userId: userId,
                country: 'US',
                sectionTitle: 'New Arrivals',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
