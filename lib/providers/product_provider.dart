import 'package:flutter/foundation.dart' hide Category;
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Product> _newArrivals = [];
  List<Product> _featured = [];
  List<Product> _onSale = [];
  List<Category> _categories = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _error;

  // Filters
  String? _selectedCategoryId;
  double? _minPrice;
  double? _maxPrice;
  String? _searchQuery;

  List<Product> get products => _products;
  List<Product> get newArrivals => _newArrivals;
  List<Product> get featured => _featured;
  List<Product> get onSale => _onSale;
  List<Category> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String? get selectedCategoryId => _selectedCategoryId;

  Future<void> loadHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _productService.getNewArrivals(limit: 10),
        _productService.getFeaturedProducts(limit: 10),
        _productService.getOnSaleProducts(limit: 10),
        _productService.getCategories(),
      ]);

      _newArrivals = results[0] as List<Product>;
      _featured = results[1] as List<Product>;
      _onSale = results[2] as List<Product>;
      _categories = results[3] as List<Category>;
      _error = null;
    } catch (e) {
      _error = 'Error al cargar los datos';
      debugPrint('Load home data error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _products = [];
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _productService.getProducts(
        categoryId: _selectedCategoryId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        search: _searchQuery,
        page: _currentPage,
      );

      if (result.length < 20) {
        _hasMore = false;
      }

      _products.addAll(result);
      _currentPage++;
      _error = null;
    } catch (e) {
      _error = 'Error al cargar productos';
      debugPrint('Load products error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProductDetail(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedProduct = await _productService.getProductById(id);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar el producto';
      debugPrint('Load product detail error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    loadProducts(refresh: true);
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    loadProducts(refresh: true);
  }

  void setSearch(String? query) {
    _searchQuery = query;
    loadProducts(refresh: true);
  }

  void clearFilters() {
    _selectedCategoryId = null;
    _minPrice = null;
    _maxPrice = null;
    _searchQuery = null;
    loadProducts(refresh: true);
  }

  // --- Admin ---
  List<Product> _adminProducts = [];
  List<Product> get adminProducts => _adminProducts;

  Future<void> loadAdminProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _adminProducts = await _productService.getAllProducts();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar productos';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final product = await _productService.createProduct(data);
    _adminProducts.insert(0, product);
    notifyListeners();
    return product;
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> data) async {
    final product = await _productService.updateProduct(id, data);
    final index = _adminProducts.indexWhere((p) => p.id == id);
    if (index != -1) {
      _adminProducts[index] = product;
    }
    notifyListeners();
    return product;
  }

  Future<void> deleteProduct(String id) async {
    await _productService.deleteProduct(id);
    _adminProducts.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
