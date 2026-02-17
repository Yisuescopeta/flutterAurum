import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Order> createOrder({
    required List<CartItem> items,
    required int totalCents,
    required String customerEmail,
    String? shippingAddress,
    String? shippingCity,
    String? shippingPostalCode,
    String? shippingPhone,
    String? notes,
    String? stripeSessionId,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;

      // Create order
      final orderData = await _client
          .from('orders')
          .insert({
            'user_id': userId,
            'customer_email': customerEmail,
            'total_amount': totalCents,
            'status': 'paid',
            'stripe_session_id': stripeSessionId,
            'shipping_address': shippingAddress ?? 'No especificada',
            'shipping_city': shippingCity ?? 'No especificada',
            'shipping_postal_code': shippingPostalCode ?? '00000',
            'shipping_phone': shippingPhone,
            'notes': notes,
          })
          .select()
          .single();

      final orderId = orderData['id'] as String;

      // Create order items
      final orderItems = items
          .map(
            (item) => {
              'order_id': orderId,
              'product_name': item.productName,
              'quantity': item.quantity,
              'price_at_purchase': item.price,
            },
          )
          .toList();

      await _client.from('order_items').insert(orderItems);

      return Order.fromJson(orderData);
    } catch (e) {
      debugPrint('Create order error: $e');
      rethrow;
    }
  }

  Future<List<Order>> getUserOrders() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get user orders error: $e');
      return [];
    }
  }

  // --- Admin methods ---

  Future<List<Order>> getAllOrders({String? statusFilter}) async {
    try {
      var query = _client
          .from('orders')
          .select('*, order_items(*), profiles(full_name, email)');

      if (statusFilter != null && statusFilter.isNotEmpty) {
        query = query.eq('status', statusFilter);
      }

      final data = await query.order('created_at', ascending: false);

      return (data as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get all orders error: $e');
      rethrow;
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      final data = await _client
          .from('orders')
          .select('*, order_items(*), profiles(full_name, email)')
          .eq('id', orderId)
          .maybeSingle();

      if (data != null) {
        return Order.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Get order by id error: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{'status': newStatus};

      if (newStatus == 'shipped') {
        updateData['shipped_at'] = DateTime.now().toIso8601String();
      } else if (newStatus == 'delivered') {
        updateData['delivered_at'] = DateTime.now().toIso8601String();
      } else if (newStatus == 'cancelled') {
        updateData['cancelled_at'] = DateTime.now().toIso8601String();
        if (notes != null) updateData['cancellation_reason'] = notes;
      }

      await _client.from('orders').update(updateData).eq('id', orderId);

      // Add to status history
      final userId = _client.auth.currentUser?.id;
      await _client.from('order_status_history').insert({
        'order_id': orderId,
        'status': newStatus,
        'notes': notes,
        'created_by': userId,
      });
    } catch (e) {
      debugPrint('Update order status error: $e');
      rethrow;
    }
  }

  // --- Stripe Checkout ---

  Future<String?> createStripeCheckoutSession({
    required List<CartItem> items,
    required String customerEmail,
  }) async {
    try {
      final stripeSecretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';
      if (stripeSecretKey.isEmpty) {
        debugPrint('Stripe secret key not configured');
        return null;
      }

      final lineItems = items
          .map(
            (item) => {
              'price_data': {
                'currency': 'eur',
                'product_data': {'name': item.productName},
                'unit_amount': item.price,
              },
              'quantity': item.quantity,
            },
          )
          .toList();

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/checkout/sessions'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: _encodeStripeBody({
          'mode': 'payment',
          'customer_email': customerEmail,
          'success_url':
              '${dotenv.env['SITE_URL'] ?? 'https://example.com'}/order-success?session_id={CHECKOUT_SESSION_ID}',
          'cancel_url':
              '${dotenv.env['SITE_URL'] ?? 'https://example.com'}/cart',
          'line_items': lineItems,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['url'] as String?;
      } else {
        debugPrint('Stripe error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Create Stripe session error: $e');
      return null;
    }
  }

  String _encodeStripeBody(Map<String, dynamic> data) {
    final parts = <String>[];
    _flattenMap(data, '', parts);
    return parts.join('&');
  }

  void _flattenMap(dynamic data, String prefix, List<String> parts) {
    if (data is Map) {
      data.forEach((key, value) {
        final newPrefix = prefix.isEmpty ? key.toString() : '$prefix[$key]';
        _flattenMap(value, newPrefix, parts);
      });
    } else if (data is List) {
      for (var i = 0; i < data.length; i++) {
        _flattenMap(data[i], '$prefix[$i]', parts);
      }
    } else {
      parts.add(
        '${Uri.encodeComponent(prefix)}=${Uri.encodeComponent(data.toString())}',
      );
    }
  }

  // --- Dashboard stats ---

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Total orders
      final allOrders = await _client
          .from('orders')
          .select('id, total_amount, status, created_at');

      final todayOrders = (allOrders as List).where((o) {
        final created = DateTime.parse(o['created_at'] as String);
        return created.isAfter(startOfDay);
      }).toList();

      final monthOrders = allOrders.where((o) {
        final created = DateTime.parse(o['created_at'] as String);
        return created.isAfter(startOfMonth);
      }).toList();

      final totalRevenue = allOrders.fold<int>(
        0,
        (sum, o) => sum + ((o['total_amount'] as int?) ?? 0),
      );

      final monthRevenue = monthOrders.fold<int>(
        0,
        (sum, o) => sum + ((o['total_amount'] as int?) ?? 0),
      );

      // Total customers
      final customers = await _client
          .from('profiles')
          .select('id')
          .eq('role', 'customer');

      // Total products
      final products = await _client
          .from('products')
          .select('id')
          .eq('is_active', true);

      return {
        'totalOrders': allOrders.length,
        'todayOrders': todayOrders.length,
        'monthOrders': monthOrders.length,
        'totalRevenue': totalRevenue / 100,
        'monthRevenue': monthRevenue / 100,
        'totalCustomers': (customers as List).length,
        'totalProducts': (products as List).length,
      };
    } catch (e) {
      debugPrint('Get dashboard stats error: $e');
      return {};
    }
  }
}
