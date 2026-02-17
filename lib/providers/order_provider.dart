import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<Order> _userOrders = [];
  List<Order> _allOrders = [];
  Order? _selectedOrder;
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = false;
  String? _error;

  List<Order> get userOrders => _userOrders;
  List<Order> get allOrders => _allOrders;
  Order? get selectedOrder => _selectedOrder;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userOrders = await _orderService.getUserOrders();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar pedidos';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Order?> createOrder({
    required List<CartItem> items,
    required int totalCents,
    required String customerEmail,
    String? shippingAddress,
    String? shippingCity,
    String? shippingPostalCode,
    String? shippingPhone,
    String? stripeSessionId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final order = await _orderService.createOrder(
        items: items,
        totalCents: totalCents,
        customerEmail: customerEmail,
        shippingAddress: shippingAddress,
        shippingCity: shippingCity,
        shippingPostalCode: shippingPostalCode,
        shippingPhone: shippingPhone,
        stripeSessionId: stripeSessionId,
      );
      _userOrders.insert(0, order);
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _error = 'Error al crear el pedido';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> createStripeCheckout({
    required List<CartItem> items,
    required String customerEmail,
  }) async {
    return await _orderService.createStripeCheckoutSession(
      items: items,
      customerEmail: customerEmail,
    );
  }

  // --- Admin ---

  Future<void> loadAllOrders({String? statusFilter}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allOrders = await _orderService.getAllOrders(statusFilter: statusFilter);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar pedidos';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadOrderDetail(String orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedOrder = await _orderService.getOrderById(orderId);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar el pedido';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? notes,
  }) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus, notes: notes);
      // Refresh
      final index = _allOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        await loadAllOrders();
      }
      if (_selectedOrder?.id == orderId) {
        await loadOrderDetail(orderId);
      }
    } catch (e) {
      _error = 'Error al actualizar el estado';
      notifyListeners();
    }
  }

  Future<void> loadDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dashboardStats = await _orderService.getDashboardStats();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar estadísticas';
    }

    _isLoading = false;
    notifyListeners();
  }
}
