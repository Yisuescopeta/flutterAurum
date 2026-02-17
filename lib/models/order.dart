class Order {
  final String id;
  final DateTime? createdAt;
  final String? userId;
  final String? stripeSessionId;
  final String customerEmail;
  final int? totalAmount;
  final String status;
  final String? shippingAddress;
  final String? shippingCity;
  final String? shippingPostalCode;
  final String? shippingPhone;
  final String? notes;
  final String? trackingNumber;
  final String? carrier;
  final DateTime? estimatedDelivery;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? refundStatus;
  final DateTime? refundedAt;

  // Relationships
  final List<OrderItem> items;
  final String? customerName;

  Order({
    required this.id,
    this.createdAt,
    this.userId,
    this.stripeSessionId,
    this.customerEmail = '',
    this.totalAmount,
    this.status = 'paid',
    this.shippingAddress,
    this.shippingCity,
    this.shippingPostalCode,
    this.shippingPhone,
    this.notes,
    this.trackingNumber,
    this.carrier,
    this.estimatedDelivery,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
    this.refundStatus,
    this.refundedAt,
    this.items = const [],
    this.customerName,
  });

  String get displayTotal =>
      (totalAmount != null ? totalAmount! / 100 : 0).toStringAsFixed(2);

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem>? orderItems;
    if (json['order_items'] != null && json['order_items'] is List) {
      orderItems = (json['order_items'] as List)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    String? custName;
    if (json['profiles'] != null && json['profiles'] is Map) {
      custName = json['profiles']['full_name'] as String?;
    }

    return Order(
      id: json['id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      userId: json['user_id'] as String?,
      stripeSessionId: json['stripe_session_id'] as String?,
      customerEmail: (json['customer_email'] as String?) ?? '',
      totalAmount: json['total_amount'] as int?,
      status: (json['status'] as String?) ?? 'paid',
      shippingAddress: json['shipping_address'] as String?,
      shippingCity: json['shipping_city'] as String?,
      shippingPostalCode: json['shipping_postal_code'] as String?,
      shippingPhone: json['shipping_phone'] as String?,
      notes: json['notes'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      carrier: json['carrier'] as String?,
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.parse(json['estimated_delivery'] as String)
          : null,
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      refundStatus: json['refund_status'] as String?,
      refundedAt: json['refunded_at'] != null
          ? DateTime.parse(json['refunded_at'] as String)
          : null,
      items: orderItems ?? [],
      customerName: custName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'stripe_session_id': stripeSessionId,
      'customer_email': customerEmail,
      'total_amount': totalAmount,
      'status': status,
      'shipping_address': shippingAddress,
      'shipping_city': shippingCity,
      'shipping_postal_code': shippingPostalCode,
      'shipping_phone': shippingPhone,
      'notes': notes,
    };
  }
}

class OrderItem {
  final String id;
  final String? orderId;
  final String? productName;
  final String? size;
  final int? quantity;
  final int? priceAtPurchase;

  OrderItem({
    required this.id,
    this.orderId,
    this.productName,
    this.size,
    this.quantity,
    this.priceAtPurchase,
  });

  String get displayPrice =>
      (priceAtPurchase != null ? priceAtPurchase! / 100 : 0).toStringAsFixed(2);

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String?,
      productName: json['product_name'] as String?,
      size: json['size'] as String?,
      quantity: json['quantity'] as int?,
      priceAtPurchase: json['price_at_purchase'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_name': productName,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
    };
  }
}
