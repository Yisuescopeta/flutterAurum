import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Product>> getProducts({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? search,
    int page = 0,
    int limit = 20,
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      var query = _client
          .from('products')
          .select('*, categories(name), product_variants(*)');

      query = query.eq('is_active', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (minPrice != null) {
        query = query.gte('price', (minPrice * 100).toInt());
      }
      if (maxPrice != null) {
        query = query.lte('price', (maxPrice * 100).toInt());
      }
      if (search != null && search.isNotEmpty) {
        query = query.ilike('name', '%$search%');
      }

      final data = await query
          .order(orderBy, ascending: ascending)
          .range(page * limit, (page + 1) * limit - 1);

      return (data as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get products error: $e');
      rethrow;
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final data = await _client
          .from('products')
          .select('*, categories(name), product_variants(*)')
          .eq('id', id)
          .maybeSingle();
      if (data != null) {
        return Product.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Get product by id error: $e');
      rethrow;
    }
  }

  Future<List<Product>> getNewArrivals({int limit = 10}) async {
    try {
      final data = await _client
          .from('products')
          .select('*, categories(name), product_variants(*)')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get new arrivals error: $e');
      return [];
    }
  }

  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      final data = await _client
          .from('products')
          .select('*, categories(name), product_variants(*)')
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get featured products error: $e');
      return [];
    }
  }

  Future<List<Product>> getOnSaleProducts({int limit = 10}) async {
    try {
      final data = await _client
          .from('products')
          .select('*, categories(name), product_variants(*)')
          .eq('is_active', true)
          .eq('is_on_sale', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get on sale products error: $e');
      return [];
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final data = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('name');

      return (data as List)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get categories error: $e');
      return [];
    }
  }

  // --- Admin methods ---

  Future<List<Product>> getAllProducts({int page = 0, int limit = 50}) async {
    try {
      final data = await _client
          .from('products')
          .select('*, categories(name), product_variants(*)')
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);

      return (data as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get all products error: $e');
      rethrow;
    }
  }

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      final data = await _client
          .from('products')
          .insert(productData)
          .select('*, categories(name), product_variants(*)')
          .single();
      return Product.fromJson(data);
    } catch (e) {
      debugPrint('Create product error: $e');
      rethrow;
    }
  }

  Future<Product> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    try {
      final data = await _client
          .from('products')
          .update(productData)
          .eq('id', id)
          .select('*, categories(name), product_variants(*)')
          .single();
      return Product.fromJson(data);
    } catch (e) {
      debugPrint('Update product error: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _client.from('products').delete().eq('id', id);
    } catch (e) {
      debugPrint('Delete product error: $e');
      rethrow;
    }
  }

  // Product variants
  Future<void> upsertVariant(Map<String, dynamic> variantData) async {
    await _client.from('product_variants').upsert(variantData);
  }

  Future<void> deleteVariant(String variantId) async {
    await _client.from('product_variants').delete().eq('id', variantId);
  }
}
