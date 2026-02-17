import 'product_variant.dart';

class Product {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final int price; // in cents
  final int? compareAtPrice;
  final int stock;
  final String? sku;
  final String? categoryId;
  final List<String> images;
  final List<String> colors;
  final String? material;
  final bool isFeatured;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isOnSale;
  final int? salePrice;
  final DateTime? saleStartedAt;
  final Map<String, dynamic>? sizes;

  // Relationships (populated separately)
  final String? categoryName;
  final List<ProductVariant>? variants;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.compareAtPrice,
    this.stock = 0,
    this.sku,
    this.categoryId,
    this.images = const [],
    this.colors = const [],
    this.material,
    this.isFeatured = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.isOnSale = false,
    this.salePrice,
    this.saleStartedAt,
    this.sizes,
    this.categoryName,
    this.variants,
  });

  // Price display helpers (DB stores cents)
  double get displayPrice => price / 100;
  double? get displaySalePrice => salePrice != null ? salePrice! / 100 : null;
  double? get displayCompareAtPrice =>
      compareAtPrice != null ? compareAtPrice! / 100 : null;

  double get effectivePrice =>
      isOnSale && salePrice != null ? salePrice! / 100 : price / 100;

  int get discountPercentage {
    if (!isOnSale || salePrice == null || salePrice! >= price) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }

  String get mainImage => images.isNotEmpty ? images.first : '';

  bool get hasDiscount => isOnSale && salePrice != null && salePrice! < price;

  List<String> get availableSizes {
    if (variants != null && variants!.isNotEmpty) {
      return variants!.where((v) => v.stock > 0).map((v) => v.size).toList();
    }
    if (sizes != null) {
      return sizes!.keys.toList();
    }
    return [];
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        imagesList = (json['images'] as List).map((e) => e.toString()).toList();
      }
    }

    List<String> colorsList = [];
    if (json['colors'] != null) {
      if (json['colors'] is List) {
        colorsList = (json['colors'] as List).map((e) => e.toString()).toList();
      }
    }

    Map<String, dynamic>? sizesMap;
    if (json['sizes'] != null && json['sizes'] is Map) {
      sizesMap = Map<String, dynamic>.from(json['sizes'] as Map);
    }

    // Handle nested category
    String? catName;
    if (json['categories'] != null && json['categories'] is Map) {
      catName = json['categories']['name'] as String?;
    }

    // Handle nested variants
    List<ProductVariant>? variantsList;
    if (json['product_variants'] != null && json['product_variants'] is List) {
      variantsList = (json['product_variants'] as List)
          .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      price: json['price'] as int,
      compareAtPrice: json['compare_at_price'] as int?,
      stock: (json['stock'] as int?) ?? 0,
      sku: json['sku'] as String?,
      categoryId: json['category_id'] as String?,
      images: imagesList,
      colors: colorsList,
      material: json['material'] as String?,
      isFeatured: (json['is_featured'] as bool?) ?? false,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isOnSale: (json['is_on_sale'] as bool?) ?? false,
      salePrice: json['sale_price'] as int?,
      saleStartedAt: json['sale_started_at'] != null
          ? DateTime.parse(json['sale_started_at'] as String)
          : null,
      sizes: sizesMap,
      categoryName: catName,
      variants: variantsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'compare_at_price': compareAtPrice,
      'stock': stock,
      'sku': sku,
      'category_id': categoryId,
      'images': images,
      'colors': colors,
      'material': material,
      'is_featured': isFeatured,
      'is_active': isActive,
      'is_on_sale': isOnSale,
      'sale_price': salePrice,
      'sizes': sizes,
    };
  }
}
