import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/product.dart';
import '../../services/db_service.dart';
import '../../config/constants.dart';

class DairyFormPage extends StatefulWidget {
  final Product? product; // null for create, non-null for edit

  const DairyFormPage({super.key, this.product});

  @override
  State<DairyFormPage> createState() => _DairyFormPageState();
}

class _DairyFormPageState extends State<DairyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _returnsController = TextEditingController();

  String _selectedCategory = AppConstants.dairyCategories.first;
  bool _isLoading = false;
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _buyPriceController.text = product.buyPrice.toString();
    _sellPriceController.text = product.sellPrice.toString();
    _stockController.text = product.stock.toString();
    _returnsController.text = product.returns.toString();
    _selectedCategory = product.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _stockController.dispose();
    _returnsController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final product = Product(
        id: _isEditing ? widget.product!.id : null,
        name: _nameController.text.trim(),
        buyPrice: double.parse(_buyPriceController.text),
        sellPrice: double.parse(_sellPriceController.text),
        stock: int.parse(_stockController.text),
        returns: int.parse(_returnsController.text),
        date: _isEditing ? widget.product!.date : DateTime.now(),
        category: _selectedCategory.toLowerCase(),
      );

      Product savedProduct;
      if (_isEditing) {
        await DBService.updateDairyProduct(widget.product!.id!, product);
        savedProduct = product;
      } else {
        savedProduct = await DBService.addDairyProduct(product);
      }

      if (mounted) {
        Navigator.pop(context, savedProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? AppConstants.updateSuccess : AppConstants.saveSuccess),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? suffix,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          prefixIcon: Icon(icon, color: const Color(0xFF00BFA5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        onChanged: (value) => setState(() => _selectedCategory = value!),
        decoration: InputDecoration(
          labelText: 'Category',
          prefixIcon: const Icon(Icons.category, color: Color(0xFF00BFA5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: AppConstants.dairyCategories
            .map((category) => DropdownMenuItem(
          value: category,
          child: Text(category),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildProfitPreview() {
    final buyPrice = double.tryParse(_buyPriceController.text) ?? 0;
    final sellPrice = double.tryParse(_sellPriceController.text) ?? 0;
    final stock = int.tryParse(_stockController.text) ?? 0;
    final returns = int.tryParse(_returnsController.text) ?? 0;

    final availableStock = stock - returns;
    final profit = (sellPrice - buyPrice) * availableStock;
    final profitColor = profit >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: profitColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: profitColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Stock:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '$availableStock units',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profit per unit:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '₹${(sellPrice - buyPrice).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: profitColor,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Expected Profit:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '₹${profit.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: profitColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add New Product'),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BFA5), Color(0xFF00ACC1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_drink,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isEditing ? 'Update Product Details' : 'Add New Dairy Product',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEditing ? 'Modify the product information below' : 'Fill in the details to add a new product',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Fields
              _buildFormField(
                controller: _nameController,
                label: 'Product Name',
                hint: 'e.g., Fresh Milk, Yogurt',
                icon: Icons.local_drink,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Product name is required';
                  if (value!.length < AppConstants.minNameLength) return 'Name too short';
                  if (value.length > AppConstants.maxNameLength) return 'Name too long';
                  return null;
                },
              ),

              _buildCategoryDropdown(),

              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      controller: _buyPriceController,
                      label: 'Buy Price',
                      hint: '0.00',
                      icon: Icons.shopping_cart,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      suffix: '₹',
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        final price = double.tryParse(value!);
                        if (price == null) return 'Invalid price';
                        if (price < AppConstants.minPrice) return 'Price too low';
                        if (price > AppConstants.maxPrice) return 'Price too high';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      controller: _sellPriceController,
                      label: 'Sell Price',
                      hint: '0.00',
                      icon: Icons.sell,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      suffix: '₹',
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        final price = double.tryParse(value!);
                        if (price == null) return 'Invalid price';
                        if (price < AppConstants.minPrice) return 'Price too low';
                        if (price > AppConstants.maxPrice) return 'Price too high';

                        final buyPrice = double.tryParse(_buyPriceController.text) ?? 0;
                        if (price < buyPrice) return 'Sell price should be ≥ buy price';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      controller: _stockController,
                      label: 'Total Stock',
                      hint: '0',
                      icon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      suffix: 'units',
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        final stock = int.tryParse(value!);
                        if (stock == null) return 'Invalid number';
                        if (stock < AppConstants.minStock) return 'Stock too low';
                        if (stock > AppConstants.maxStock) return 'Stock too high';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      controller: _returnsController,
                      label: 'Returns',
                      hint: '0',
                      icon: Icons.keyboard_return,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      suffix: 'units',
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        final returns = int.tryParse(value!);
                        if (returns == null) return 'Invalid number';
                        if (returns < 0) return 'Cannot be negative';

                        final stock = int.tryParse(_stockController.text) ?? 0;
                        if (returns > stock) return 'Returns cannot exceed stock';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // Profit Preview
              _buildProfitPreview(),

              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    _isEditing ? 'Update Product' : 'Save Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}