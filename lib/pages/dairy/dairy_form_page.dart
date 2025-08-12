import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/db_service.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

class DairyFormPage extends StatefulWidget {
  final Product? product;

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
  
  bool _isLoading = false;
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.product!.name;
      _buyPriceController.text = widget.product!.buyPrice.toString();
      _sellPriceController.text = widget.product!.sellPrice.toString();
      _stockController.text = widget.product!.stock.toString();
      _returnsController.text = widget.product!.returns.toString();
    }
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
        id: widget.product?.id,
        name: _nameController.text.trim(),
        buyPrice: double.parse(_buyPriceController.text.trim()),
        sellPrice: double.parse(_sellPriceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        returns: int.parse(_returnsController.text.trim()),
        date: widget.product?.date,
      );

      if (_isEditing) {
        await DBService.updateDairyProduct(product);
      } else {
        await DBService.addDairyProduct(product);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product ${_isEditing ? 'updated' : 'added'} successfully!'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_isEditing ? 'Edit' : 'Add'} Product'),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomInputField(
              label: 'Product Name',
              controller: _nameController,
              isRequired: true,
              prefixIcon: Icons.local_drink,
              validator: (value) => Validators.validateRequired(value, 'Product name'),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    label: 'Buy Price (₹)',
                    controller: _buyPriceController,
                    isRequired: true,
                    prefixIcon: Icons.shopping_cart,
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.validatePositiveNumber(value, 'Buy price'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomInputField(
                    label: 'Sell Price (₹)',
                    controller: _sellPriceController,
                    isRequired: true,
                    prefixIcon: Icons.sell,
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.validatePositiveNumber(value, 'Sell price'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    label: 'Stock Count',
                    controller: _stockController,
                    isRequired: true,
                    prefixIcon: Icons.inventory,
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.validateInteger(value, 'Stock count'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomInputField(
                    label: 'Returns',
                    controller: _returnsController,
                    isRequired: true,
                    prefixIcon: Icons.keyboard_return,
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.validateInteger(value, 'Returns'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            Card(
              color: const Color(0xFF00BFA5).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Profit Calculation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Per Unit: ₹${(_sellPriceController.text.isNotEmpty && _buyPriceController.text.isNotEmpty) ? (double.tryParse(_sellPriceController.text) ?? 0) - (double.tryParse(_buyPriceController.text) ?? 0) : 0}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Total: ₹${(_sellPriceController.text.isNotEmpty && _buyPriceController.text.isNotEmpty && _stockController.text.isNotEmpty && _returnsController.text.isNotEmpty) ? ((double.tryParse(_sellPriceController.text) ?? 0) - (double.tryParse(_buyPriceController.text) ?? 0)) * ((int.tryParse(_stockController.text) ?? 0) - (int.tryParse(_returnsController.text) ?? 0)) : 0}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            CustomButton(
              text: _isEditing ? 'Update Product' : 'Add Product',
              onPressed: _saveProduct,
              isLoading: _isLoading,
              backgroundColor: const Color(0xFF00BFA5),
              icon: _isEditing ? Icons.update : Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}
