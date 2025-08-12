import 'package:flutter/material.dart';
import '../../models/shop.dart';
import '../../models/bill.dart';
import '../../services/db_service.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

class BillFormPage extends StatefulWidget {
  final Shop shop;
  final Bill? bill;

  const BillFormPage({super.key, required this.shop, this.bill});

  @override
  State<BillFormPage> createState() => _BillFormPageState();
}

class _BillFormPageState extends State<BillFormPage> {
  final _formKey = GlobalKey<FormState>();
  List<BillItemForm> _items = [];
  bool _isLoading = false;

  bool get _isEditing => widget.bill != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _items = widget.bill!.items.map((item) => BillItemForm.fromBillItem(item)).toList();
    } else {
      _addNewItem();
    }
  }

  @override
  void dispose() {
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addNewItem() {
    setState(() {
      _items.add(BillItemForm());
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items[index].dispose();
        _items.removeAt(index);
      });
    }
  }

  double get _total {
    return _items.fold(0.0, (sum, item) => sum + item.total);
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;

    final validItems = _items
        .where((item) => item.nameController.text.isNotEmpty)
        .map((item) => item.toBillItem())
        .toList();

    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bill = Bill(
        id: widget.bill?.id,
        shopId: widget.shop.id!,
        shopName: widget.shop.name,
        items: validItems,
        createdDate: widget.bill?.createdDate,
      );

      if (_isEditing) {
        await DBService.updateBill(bill);
      } else {
        await DBService.addBill(bill);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bill ${_isEditing ? 'updated' : 'created'} successfully!'),
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

  Widget _buildItemCard(int index) {
    final item = _items[index];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Item ${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_items.length > 1)
                  IconButton(
                    onPressed: () => _removeItem(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            CustomInputField(
              label: 'Product Name',
              controller: item.nameController,
              isRequired: true,
              prefixIcon: Icons.shopping_bag,
              validator: (value) => Validators.validateRequired(value, 'Product name'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    label: 'Quantity',
                    controller: item.quantityController,
                    isRequired: true,
                    prefixIcon: Icons.format_list_numbered,
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.validateInteger(value, 'Quantity'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomInputField(
                    label: 'Unit Price (₹)',
                    controller: item.priceController,
                    isRequired: true,
                    prefixIcon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.validatePositiveNumber(value, 'Unit price'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹${item.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_isEditing ? 'Edit' : 'New'} Bill'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shop: ${widget.shop.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Total: ₹${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) => _buildItemCard(index),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Add Item',
                      onPressed: _addNewItem,
                      isOutlined: true,
                      backgroundColor: const Color(0xFF2196F3),
                      icon: Icons.add,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _isEditing ? 'Update Bill' : 'Create Bill',
                      onPressed: _saveBill,
                      isLoading: _isLoading,
                      backgroundColor: const Color(0xFF2196F3),
                      icon: _isEditing ? Icons.update : Icons.save,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BillItemForm {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  BillItemForm({
    String? name,
    int? quantity,
    double? price,
  }) : nameController = TextEditingController(text: name ?? ''),
        quantityController = TextEditingController(text: quantity?.toString() ?? '1'),
        priceController = TextEditingController(text: price?.toString() ?? '');

  factory BillItemForm.fromBillItem(BillItem item) {
    return BillItemForm(
      name: item.productName,
      quantity: item.quantity,
      price: item.unitPrice,
    );
  }

  BillItem toBillItem() {
    return BillItem(
      productName: nameController.text.trim(),
      quantity: int.tryParse(quantityController.text) ?? 1,
      unitPrice: double.tryParse(priceController.text) ?? 0.0,
    );
  }

  double get total {
    final qty = int.tryParse(quantityController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0.0;
    return qty * price;
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }
}
