import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<String>> getFavoriteProductIds() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _client
          .from('favorites')
          .select('product_id')
          .eq('user_id', userId);

      return (data as List).map((e) => e['product_id'] as String).toList();
    } catch (e) {
      debugPrint('Get favorites error: $e');
      return [];
    }
  }

  Future<bool> isFavorite(String productId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final data = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      return data != null;
    } catch (e) {
      debugPrint('Check favorite error: $e');
      return false;
    }
  }

  Future<void> toggleFavorite(String productId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final existing = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        await _client.from('favorites').delete().eq('id', existing['id']);
      } else {
        await _client.from('favorites').insert({
          'user_id': userId,
          'product_id': productId,
        });
      }
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(String productId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
    } catch (e) {
      debugPrint('Remove favorite error: $e');
      rethrow;
    }
  }
}
