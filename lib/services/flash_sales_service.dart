import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aivo/utils/app_logger.dart';
import 'package:aivo/models/FlashSale.dart';

class FlashSalesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all active flash sales
  Future<List<FlashSale>> getActiveFlashSales({int limit = 20}) async {
    try {
      final response = await _supabase.rpc(
        'get_active_flash_sales',
        params: {
          'p_limit': limit,
        },
      ) as List;

      return response.map((json) => FlashSale.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching flash sales: $e', tag: 'FlashSalesService');
      return [];
    }
  }

  /// Get flash sales by category
  Future<List<FlashSale>> getFlashSalesByCategory({
    required String categoryId,
    int limit = 20,
  }) async {
    try {
      final now = DateTime.now();
      final response = await _supabase
          .from('flash_sales')
          .select(
            'id, product_id, products!inner(title, price, image_url, stock, category_id), discount_percent, original_price, sale_price, ends_at, max_quantity, sold_quantity'
          )
          .eq('is_active', true)
          .eq('products.category_id', categoryId)
          .gt('ends_at', now.toIso8601String())
          .limit(limit);

      return response
          .map((json) => FlashSale(
                id: json['id'],
                productId: json['product_id'],
                productTitle: json['products']['title'],
                categoryName: null,
                discountPercent: double.tryParse(json['discount_percent'].toString()) ?? 0.0,
                originalPrice: double.tryParse(json['original_price'].toString()) ?? 0.0,
                salePrice: double.tryParse(json['sale_price'].toString()) ?? 0.0,
                endsAt: DateTime.parse(json['ends_at']),
                timeRemaining: _getTimeRemaining(DateTime.parse(json['ends_at'])),
                maxQuantity: json['max_quantity'],
                soldQuantity: json['sold_quantity'] ?? 0,
                stockAvailable: json['products']['stock'] ?? 0,
                imageUrl: json['products']['image_url'] ?? '',
              ))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching category flash sales: $e', tag: 'FlashSalesService');
      return [];
    }
  }

  /// Create a new flash sale (admin only)
  Future<bool> createFlashSale({
    required String productId,
    required double discountPercent,
    required double originalPrice,
    required double salePrice,
    required DateTime endsAt,
    int? maxQuantity,
  }) async {
    try {
      await _supabase.from('flash_sales').insert({
        'product_id': productId,
        'discount_percent': discountPercent,
        'original_price': originalPrice,
        'sale_price': salePrice,
        'ends_at': endsAt.toIso8601String(),
        'started_at': DateTime.now().toIso8601String(),
        'max_quantity': maxQuantity,
        'is_active': true,
      });
      return true;
    } catch (e) {
      AppLogger.error('Error creating flash sale: $e', tag: 'FlashSalesService');
      return false;
    }
  }

  /// Update flash sale
  Future<bool> updateFlashSale({
    required String saleId,
    double? discountPercent,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (discountPercent != null) updates['discount_percent'] = discountPercent;
      if (isActive != null) updates['is_active'] = isActive;

      await _supabase.from('flash_sales').update(updates).eq('id', saleId);
      return true;
    } catch (e) {
      AppLogger.error('Error updating flash sale: $e', tag: 'FlashSalesService');
      return false;
    }
  }

  /// Helper: Format time remaining
  String _getTimeRemaining(DateTime endsAt) {
    final now = DateTime.now();
    final difference = endsAt.difference(now);

    if (difference.isNegative) return 'Ended';
    if (difference.inDays > 0) return '${difference.inDays}d';
    if (difference.inHours > 0) return '${difference.inHours}h';
    return '${difference.inMinutes}m';
  }
}
