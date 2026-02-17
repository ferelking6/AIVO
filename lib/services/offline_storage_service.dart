import 'package:hive_flutter/hive_flutter.dart';
import 'package:aivo/utils/app_logger.dart';
import '../models/product.dart';

class OfflineStorageService {
  static const String _productsBox = 'products_cache';
  static const String _cartBox = 'cart_cache';
  static const String _favoritesBox = 'favorites_cache';
  static const String _lastSyncBox = 'last_sync';

  static final OfflineStorageService _instance =
      OfflineStorageService._internal();

  factory OfflineStorageService() {
    return _instance;
  }

  OfflineStorageService._internal();

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Register adapters if using Hive models
      // Hive.registerAdapter(ProductAdapter());

      // Open boxes
      await Hive.openBox(_productsBox);
      await Hive.openBox(_cartBox);
      await Hive.openBox(_favoritesBox);
      await Hive.openBox<String>(_lastSyncBox);

      AppLogger.log('Offline storage initialized successfully', tag: 'OfflineStorage');
    } catch (e) {
      AppLogger.error('Error initializing offline storage: $e', tag: 'OfflineStorage');
    }
  }

  // ==================== Products Cache ====================

  /// Cache products locally
  Future<void> cacheProducts(List<Product> products) async {
    try {
      final productsBox = Hive.box(_productsBox);
      final data = products.map((p) => p.toJson()).toList();
      await productsBox.putAll({
        'all_products': data,
        'sync_time': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      AppLogger.error('Error caching products: $e', tag: 'OfflineStorage');
    }
  }

  /// Get cached products
  List<Product> getCachedProducts() {
    try {
      final productsBox = Hive.box(_productsBox);
      final data = productsBox.get('all_products');

      if (data != null && data is List) {
        return data
            .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('Error retrieving cached products: $e', tag: 'OfflineStorage');
      return [];
    }
  }

  /// Cache popular products
  Future<void> cachePopularProducts(List<Product> products) async {
    try {
      final productsBox = Hive.box(_productsBox);
      final data = products.map((p) => p.toJson()).toList();
      await productsBox.put('popular_products', data);
    } catch (e) {
      AppLogger.error('Error caching popular products: $e', tag: 'OfflineStorage');
    }
  }

  /// Get cached popular products
  List<Product> getCachedPopularProducts() {
    try {
      final productsBox = Hive.box(_productsBox);
      final data = productsBox.get('popular_products');

      if (data != null && data is List) {
        return data
            .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('Error retrieving cached popular products: $e', tag: 'OfflineStorage');
      return [];
    }
  }

  // ==================== Cart Cache ====================

  /// Cache cart items
  Future<void> cacheCart(Map<String, dynamic> cartData) async {
    try {
      final cartBox = Hive.box(_cartBox);
      await cartBox.putAll(cartData);
    } catch (e) {
      AppLogger.error('Error caching cart: $e', tag: 'OfflineStorage');
    }
  }

  /// Get cached cart
  Map<String, dynamic> getCachedCart() {
    try {
      final cartBox = Hive.box(_cartBox);
      final result = <String, dynamic>{};
      for (var key in cartBox.keys) {
        result[key.toString()] = cartBox.get(key);
      }
      return result;
    } catch (e) {
      AppLogger.error('Error retrieving cached cart: $e', tag: 'OfflineStorage');
      return {};
    }
  }

  /// Clear cart cache
  Future<void> clearCartCache() async {
    try {
      final cartBox = Hive.box(_cartBox);
      await cartBox.clear();
    } catch (e) {
      AppLogger.error('Error clearing cart cache: $e', tag: 'OfflineStorage');
    }
  }

  // ==================== Favorites Cache ====================

  /// Cache favorites
  Future<void> cacheFavorites(List<int> favoriteIds) async {
    try {
      final favoritesBox = Hive.box(_favoritesBox);
      await favoritesBox.put('favorite_ids', favoriteIds);
    } catch (e) {
      AppLogger.error('Error caching favorites: $e', tag: 'OfflineStorage');
    }
  }

  /// Get cached favorites
  List<int> getCachedFavorites() {
    try {
      final favoritesBox = Hive.box(_favoritesBox);
      final data = favoritesBox.get('favorite_ids');
      if (data != null && data is List) {
        return List<int>.from(data);
      }
      return [];
    } catch (e) {
      AppLogger.error('Error retrieving cached favorites: $e', tag: 'OfflineStorage');
      return [];
    }
  }

  // ==================== Sync Management ====================

  /// Get last sync time
  DateTime? getLastSyncTime() {
    try {
      final syncBox = Hive.box<String>(_lastSyncBox);
      final time = syncBox.get('last_sync');
      if (time != null) {
        return DateTime.parse(time);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting last sync time: $e', tag: 'OfflineStorage');
      return null;
    }
  }

  /// Update last sync time
  Future<void> updateLastSyncTime() async {
    try {
      final syncBox = Hive.box<String>(_lastSyncBox);
      await syncBox.put('last_sync', DateTime.now().toIso8601String());
    } catch (e) {
      AppLogger.error('Error updating sync time: $e', tag: 'OfflineStorage');
    }
  }

  /// Check if sync is needed (older than 1 hour)
  bool isSyncNeeded() {
    final lastSync = getLastSyncTime();
    if (lastSync == null) {
      return true;
    }
    return DateTime.now().difference(lastSync).inMinutes > 60;
  }

  // ==================== General ====================

  /// Clear all cached data
  Future<void> clearAllCache() async {
    try {
      await Hive.box(_productsBox).clear();
      await Hive.box(_cartBox).clear();
      await Hive.box(_favoritesBox).clear();
      AppLogger.log('All cache cleared', tag: 'OfflineStorage');
    } catch (e) {
      AppLogger.error('Error clearing all cache: $e', tag: 'OfflineStorage');
    }
  }

  /// Get cache size
  int getCacheSize() {
    try {
      int size = 0;
      size += Hive.box(_productsBox).length;
      size += Hive.box(_cartBox).length;
      size += Hive.box(_favoritesBox).length;
      return size;
    } catch (e) {
      AppLogger.error('Error getting cache size: $e', tag: 'OfflineStorage');
      return 0;
    }
  }
}
