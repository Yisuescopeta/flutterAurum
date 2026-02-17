import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/constants.dart';
import '../../providers/product_provider.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import '../../models/category.dart';

class AdminProductFormScreen extends StatefulWidget {
  final String? productId;
  const AdminProductFormScreen({super.key, this.productId});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _materialController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _selectedCategoryId;
  bool _isOnSale = false;
  bool _isFeatured = false;
  bool _isActive = true;
  bool _isSaving = false;
  bool _isLoading = true;
  List<Category> _categories = [];
  Product? _existingProduct;

  bool get isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final productService = ProductService();

    try {
      _categories = await productService.getCategories();

      if (isEditing) {
        _existingProduct = await productService.getProductById(
          widget.productId!,
        );
        if (_existingProduct != null) {
          _nameController.text = _existingProduct!.name;
          _descriptionController.text = _existingProduct!.description ?? '';
          _priceController.text = (_existingProduct!.price / 100)
              .toStringAsFixed(2);
          if (_existingProduct!.salePrice != null) {
            _salePriceController.text = (_existingProduct!.salePrice! / 100)
                .toStringAsFixed(2);
          }
          _materialController.text = _existingProduct!.material ?? '';
          _imageUrlController.text = _existingProduct!.mainImage;
          _selectedCategoryId = _existingProduct!.categoryId;
          _isOnSale = _existingProduct!.isOnSale;
          _isFeatured = _existingProduct!.isFeatured;
          _isActive = _existingProduct!.isActive;
        }
      }
    } catch (e) {
      debugPrint('Load form data error: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final price = (double.tryParse(_priceController.text) ?? 0) * 100;
    final salePrice = _salePriceController.text.isNotEmpty
        ? (double.tryParse(_salePriceController.text) ?? 0) * 100
        : null;

    final data = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': price.round(),
      'sale_price': salePrice?.round(),
      'is_on_sale': _isOnSale,
      'is_featured': _isFeatured,
      'is_active': _isActive,
      'category_id': _selectedCategoryId,
      'material': _materialController.text.trim().isNotEmpty
          ? _materialController.text.trim()
          : null,
      'images': _imageUrlController.text.trim().isNotEmpty
          ? [_imageUrlController.text.trim()]
          : [],
    };

    try {
      final provider = context.read<ProductProvider>();
      if (isEditing) {
        await provider.updateProduct(widget.productId!, data);
      } else {
        await provider.createProduct(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Producto actualizado' : 'Producto creado',
            ),
          ),
        );
        context.go('/admin/products');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar el producto')),
        );
      }
    }

    if (mounted) setState(() => _isSaving = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _materialController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Editar Producto' : 'Nuevo Producto',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Name
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                dropdownColor: AppColors.navyCard,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          c.name,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
              const SizedBox(height: 16),

              // Price row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Precio (€)',
                        prefixText: '€ ',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _salePriceController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Precio oferta (€)',
                        prefixText: '€ ',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Material
              TextFormField(
                controller: _materialController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Material'),
              ),
              const SizedBox(height: 16),

              // Image URL
              TextFormField(
                controller: _imageUrlController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'URL de imagen',
                  prefixIcon: Icon(
                    Icons.image_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Toggles
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.navyCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Activo',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'Visible en la tienda',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      value: _isActive,
                      activeThumbColor: AppColors.gold,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    const Divider(color: AppColors.divider),
                    SwitchListTile(
                      title: const Text(
                        'En oferta',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      value: _isOnSale,
                      activeThumbColor: AppColors.gold,
                      onChanged: (v) => setState(() => _isOnSale = v),
                    ),
                    const Divider(color: AppColors.divider),
                    SwitchListTile(
                      title: const Text(
                        'Destacado',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      value: _isFeatured,
                      activeThumbColor: AppColors.gold,
                      onChanged: (v) => setState(() => _isFeatured = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.navy),
                          ),
                        )
                      : Text(isEditing ? 'GUARDAR CAMBIOS' : 'CREAR PRODUCTO'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
