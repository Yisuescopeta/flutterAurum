class ProductVariant {
  final String id;
  final String productId;
  final String size;
  final int stock;
  final String? skuVariant;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.size,
    this.stock = 0,
    this.skuVariant,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      size: json['size'] as String,
      stock: (json['stock'] as int?) ?? 0,
      skuVariant: json['sku_variant'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'size': size,
      'stock': stock,
      'sku_variant': skuVariant,
    };
  }
}
