import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item.dart';

class CartService {
  static const String _boxName = 'cart';
  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  Box get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Cart box not initialized. Call init() first.');
    }
    return _box!;
  }

  List<CartItem> getItems() {
    try {
      final items = <CartItem>[];
      for (var key in box.keys) {
        final jsonStr = box.get(key) as String?;
        if (jsonStr != null) {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          items.add(CartItem.fromJson(json));
        }
      }
      return items;
    } catch (e) {
      debugPrint('Get cart items error: $e');
      return [];
    }
  }

  Future<void> addItem(CartItem item) async {
    final key = item.uniqueKey;
    final existing = box.get(key) as String?;

    if (existing != null) {
      final existingItem = CartItem.fromJson(
        jsonDecode(existing) as Map<String, dynamic>,
      );
      existingItem.quantity += item.quantity;
      await box.put(key, jsonEncode(existingItem.toJson()));
    } else {
      await box.put(key, jsonEncode(item.toJson()));
    }
  }

  Future<void> updateQuantity(String uniqueKey, int quantity) async {
    final existing = box.get(uniqueKey) as String?;
    if (existing != null) {
      final item = CartItem.fromJson(
        jsonDecode(existing) as Map<String, dynamic>,
      );
      item.quantity = quantity;
      if (quantity <= 0) {
        await box.delete(uniqueKey);
      } else {
        await box.put(uniqueKey, jsonEncode(item.toJson()));
      }
    }
  }

  Future<void> removeItem(String uniqueKey) async {
    await box.delete(uniqueKey);
  }

  Future<void> clearCart() async {
    await box.clear();
  }

  int get itemCount {
    return getItems().fold(0, (sum, item) => sum + item.quantity);
  }

  int get totalCents {
    return getItems().fold(0, (sum, item) => sum + item.totalCents);
  }

  double get totalPrice => totalCents / 100;
}
