import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aivo/components/product_card.dart';
import 'package:aivo/models/Product.dart';
import 'package:aivo/providers/product_provider.dart';

import '../details/details_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  static String routeName = "/products";

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${productProvider.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => productProvider.fetchAllProducts(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final products = productProvider.allProducts;

              if (products.isEmpty) {
                return const Center(child: Text('No products found'));
              }

              return GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) => ProductCard(
                  product: products[index],
                  onPress: () => Navigator.pushNamed(
                    context,
                    DetailsScreen.routeName,
                    arguments: ProductDetailsArguments(product: products[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
