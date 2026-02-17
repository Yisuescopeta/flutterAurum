import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/wishlist_service.dart';
import '../services/product_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();
  final ProductService _productService = ProductService();

  Set<String> _favoriteIds = {};
  List<Product> _favoriteProducts = [];
  bool _isLoading = false;

  Set<String> get favoriteIds => _favoriteIds;
  List<Product> get favoriteProducts => _favoriteProducts;
  bool get isLoading => _isLoading;

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final ids = await _wishlistService.getFavoriteProductIds();
      _favoriteIds = ids.toSet();

      // Load product details for favorites
      _favoriteProducts = [];
      for (final id in ids) {
        final product = await _productService.getProductById(id);
        if (product != null) {
          _favoriteProducts.add(product);
        }
      }
    } catch (e) {
      debugPrint('Load favorites error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String productId) async {
    try {
      final wasFavorite = _favoriteIds.contains(productId);

      // Optimistic update
      if (wasFavorite) {
        _favoriteIds.remove(productId);
        _favoriteProducts.removeWhere((p) => p.id == productId);
      } else {
        _favoriteIds.add(productId);
      }
      notifyListeners();

      await _wishlistService.toggleFavorite(productId);

      // If added and we don't have the product details, load them
      if (!wasFavorite) {
        final product = await _productService.getProductById(productId);
        if (product != null &&
            !_favoriteProducts.any((p) => p.id == productId)) {
          _favoriteProducts.add(product);
          notifyListeners();
        }
      }
    } catch (e) {
      // Revert on error
      debugPrint('Toggle favorite error: $e');
      await loadFavorites();
    }
  }
}
