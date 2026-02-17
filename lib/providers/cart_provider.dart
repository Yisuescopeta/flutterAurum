import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItem> _items = [];
  bool _isInitialized = false;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  int get totalCents => _items.fold(0, (sum, item) => sum + item.totalCents);
  double get totalPrice => totalCents / 100;
  bool get isEmpty => _items.isEmpty;

  Future<void> init() async {
    if (_isInitialized) return;
    await _cartService.init();
    _items = _cartService.getItems();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addItem(CartItem item) async {
    await _cartService.addItem(item);
    _items = _cartService.getItems();
    notifyListeners();
  }

  Future<void> updateQuantity(String uniqueKey, int quantity) async {
    await _cartService.updateQuantity(uniqueKey, quantity);
    _items = _cartService.getItems();
    notifyListeners();
  }

  Future<void> removeItem(String uniqueKey) async {
    await _cartService.removeItem(uniqueKey);
    _items = _cartService.getItems();
    notifyListeners();
  }

  Future<void> clearCart() async {
    await _cartService.clearCart();
    _items = [];
    notifyListeners();
  }
}
