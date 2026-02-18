import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aivo/providers/flash_sales_provider.dart';
import 'package:aivo/components/flash_sale_card.dart';
import 'package:aivo/components/skeleton_loaders.dart';
import 'package:aivo/screens/details/details_screen.dart';
import 'package:aivo/models/product.dart';

class FlashSalesSection extends StatefulWidget {
  const FlashSalesSection({super.key});

  @override
  State<FlashSalesSection> createState() => _FlashSalesSectionState();
}

class _FlashSalesSectionState extends State<FlashSalesSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlashSalesProvider>().fetchFlashSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashSalesProvider>(
      builder: (context, flashSalesProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Flash Sales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to full flash sales page
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (flashSalesProvider.isLoading)
              SizedBox(
                height: 220,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      ...List.generate(3, (_) => const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SkeletonCard(
                          width: 180,
                          height: 200,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      )),
                    ],
                  ),
                ),
              )
            else if (flashSalesProvider.flashSales.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'No active flash sales',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: flashSalesProvider.flashSales.map((sale) {
                      final product = Product(
                        id: int.tryParse(sale.productId.toString()) ?? 0,
                        title: sale.productTitle,
                        price: sale.salePrice,
                        description: '',
                        images: [sale.imageUrl],
                        colors: [],
                        isFavourite: false,
                        isPopular: false,
                      );

                      return FlashSaleCard(
                        productTitle: sale.productTitle,
                        discount: sale.discountPercent,
                        originalPrice: sale.originalPrice,
                        salePrice: sale.salePrice,
                        imageUrl: sale.imageUrl,
                        timeRemaining: sale.timeRemaining,
                        soldQuantity: sale.soldQuantity,
                        maxQuantity: sale.maxQuantity,
                        onPress: () {
                          Navigator.pushNamed(
                            context,
                            DetailsScreen.routeName,
                            arguments: ProductDetailsArguments(
                              product: product,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
