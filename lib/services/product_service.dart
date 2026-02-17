import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aivo/utils/app_logger.dart';
import '../models/product.dart'';

class ProductService {
  static final ProductService _instance = ProductService._internal();

  factory ProductService() {
    return _instance;
  }

  ProductService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all products from Supabase
  Future<List<Product>> fetchAllProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            id,
            title,
            description,
            price,
            rating,
            is_popular,
            product_images:product_images(image_url, display_order),
            product_colors:product_colors(color_hex, color_name)
          ''')
          .order('created_at', ascending: false);

      final products = <Product>[];
      for (var item in response) {
        products.add(_productFromJson(item));
      }
      return products;
    } catch (e) {
      AppLogger.error('Error fetching products: $e', tag: 'ProductService');
      return [];
    }
  }

  /// Fetch popular products
  Future<List<Product>> fetchPopularProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            id,
            title,
            description,
            price,
            rating,
            is_popular,
            product_images:product_images(image_url, display_order),
            product_colors:product_colors(color_hex, color_name)
          ''')
          .eq('is_popular', true)
          .limit(6);

      final products = <Product>[];
      for (var item in response) {
        products.add(_productFromJson(item));
      }
      return products;
    } catch (e) {
      AppLogger.error('Error fetching popular products: $e', tag: 'ProductService');
      return [];
    }
  }

  /// Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            id,
            title,
            description,
            price,
            rating,
            is_popular,
            product_images:product_images(image_url, display_order),
            product_colors:product_colors(color_hex, color_name)
          ''')
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);

      final products = <Product>[];
      for (var item in response) {
        products.add(_productFromJson(item));
      }
      return products;
    } catch (e) {
      AppLogger.error('Error fetching products by category: $e', tag: 'ProductService');
      return [];
    }
  }

  /// Fetch single product by ID
  Future<Product?> fetchProductById(String productId) async {
    try {
      final response = await _supabase
          .from('products')
          .select('''
            id,
            title,
            description,
            price,
            rating,
            is_popular,
            product_images:product_images(image_url, display_order),
            product_colors:product_colors(color_hex, color_name)
          ''')
          .eq('id', productId)
          .single();

      return _productFromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching product: $e', tag: 'ProductService');
      return null;
    }
  }

  /// Fetch user's favorite products
  Future<List<Product>> fetchUserFavorites(String userId) async {
    try {
      final response = await _supabase
          .from('user_favorites')
          .select('''
            product_id,
            products:product_id(
              id,
              title,
              description,
              price,
              rating,
              is_popular,
              product_images:product_images(image_url, display_order),
              product_colors:product_colors(color_hex, color_name)
            )
          ''')
          .eq('user_id', userId);

      final products = <Product>[];
      for (var item in response) {
        if (item['products'] != null) {
          final product = _productFromJson(item['products']);
          product.isFavourite = true;
          products.add(product);
        }
      }
      return products;
    } catch (e) {
      AppLogger.error('Error fetching favorites: $e', tag: 'ProductService');
      return [];
    }
  }

  /// Toggle favorite status for a product
  Future<bool> toggleFavorite(String productId, String userId, bool isFavorite) async {
    try {
      if (isFavorite) {
        // Remove from favorites
        await _supabase
            .from('user_favorites')
            .delete()
            .eq('product_id', productId)
            .eq('user_id', userId);
      } else {
        // Add to favorites
        await _supabase.from('user_favorites').insert({
          'product_id': productId,
          'user_id': userId,
        });
      }
      return true;
    } catch (e) {
      AppLogger.error('Error toggling favorite: $e', tag: 'ProductService');
      return false;
    }
  }

  /// Convert Supabase JSON response to Product object
  Product _productFromJson(Map<String, dynamic> json) {
    final imagesList = json['product_images'] ?? [];
    final colorsList = json['product_colors'] ?? [];

    // Sort images by display_order
    if (imagesList is List) {
      imagesList.sort((a, b) =>
          (a['display_order'] as int).compareTo(b['display_order'] as int));
    }

    // Extract image URLs
    final images = (imagesList as List)
        .map((img) => img['image_url'] as String)
        .toList();

    // Convert hex colors to Color objects
    final colors = (colorsList as List)
        .map((color) => _hexToColor(color['color_hex'] as String))
        .toList();

    // If no images, use placeholder
    if (images.isEmpty) {
      images.add('https://via.placeholder.com/300?text=No+Image');
    }

    // If no colors, use default colors
    if (colors.isEmpty) {
      colors.addAll([
        const Color(0xFFF6625E),
        const Color(0xFF836DB8),
        const Color(0xFFDECB9C),
        Colors.white,
      ]);
    }

    return Product(
      id: int.tryParse(json['id'].toString().split('-').first.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      title: json['title'] ?? 'Unknown',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      images: images,
      colors: colors,
      isPopular: json['is_popular'] ?? false,
      isFavourite: false,
    );
  }

  /// Convert hex color string to Flutter Color
  Color _hexToColor(String hexString) {
    try {
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF$hexString';
      }
      return Color(int.parse(hexString, radix: 16));
    } catch (e) {
      AppLogger.error('Error converting hex color: $e', tag: 'ProductService');
      return Colors.grey;
    }
  }

  /// Get image URL for Supabase storage
  String getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return _supabase.storage.from('products').getPublicUrl(imagePath);
  }
}
