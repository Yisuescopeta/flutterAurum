class CartItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final int price; // in cents
  final String size;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    this.imageUrl = '',
    required this.price,
    required this.size,
    this.quantity = 1,
  });

  double get displayPrice => price / 100;
  double get totalPrice => (price * quantity) / 100;
  double get displayTotal => totalPrice;
  int get totalCents => price * quantity;

  String get uniqueKey => '${productId}_$size';

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      imageUrl: (json['image_url'] as String?) ?? '',
      price: json['price'] as int,
      size: json['size'] as String,
      quantity: (json['quantity'] as int?) ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'image_url': imageUrl,
      'price': price,
      'size': size,
      'quantity': quantity,
    };
  }
}
