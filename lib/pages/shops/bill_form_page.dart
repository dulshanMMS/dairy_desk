import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/shop.dart';
import '../../models/bill.dart';
import '../../models/product.dart';
import '../../services/db_service.dart';
import '../../config/constants.dart';

class BillFormPage extends StatefulWidget {
  final Shop shop;
  final Bill? bill; // null for create, non-null for edit

  const BillFormPage({super.key, required this.shop, this.bill});

  @override
  State<BillFormPage> createState() => _BillFormPageState();
}

class _BillFormPageState extends State<BillFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _discountController = TextEditingController(text: '0');

  List<Product> _availableProducts = [];
  List<BillItem> _billItems = [];
  BillStatus _billStatus = BillStatus.draft;
  PaymentMethod? _paymentMethod;
  DateTime? _dueDate;
  bool _isLoading = false;
  bool get _isEditing => widget.bill != null;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final bill = widget.bill!;
    _customerNameController.text = bill.customerName;
    _customerPhoneController.text = bill.customerPhone;
    _customerAddressController.text = bill.customerAddress;
    _discountController.text = bill.discount.toString();
    _billItems = List.from(bill.items);
    _billStatus = bill.status;
    _paymentMethod = bill.paymentMethod;
    _dueDate = bill.dueDate;
  }

  Future<void> _loadProducts() async {
    try {
      final products = await DBService.getDairyProducts();
      setState(() {
        _availableProducts = products.where((p) => p.availableStock > 0).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _addBillItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductSelectionModal(
        products: _availableProducts,
        onProductSelected: (product, quantity) {
          setState(() {
            // Check if product already exists in bill
            final existingIndex = _billItems.indexWhere((item) => item.productId == product.id);
            if (existingIndex >= 0) {
              // Update existing item quantity
              final existingItem = _billItems[existingIndex];
              _billItems[existingIndex] = BillItem(
                productId: existingItem.productId,
                productName: existingItem.productName,
                quantity: existingItem.quantity + quantity,
                unitPrice: existingItem.unitPrice,
                discount: existingItem.discount,
              );
            } else {
              // Add new item
              _billItems.add(BillItem(
                productId: product.id!,
                productName: product.name,
                quantity: quantity,
                unitPrice: product.sellPrice,
                discount: 0,
              ));
            }
          });
        },
      ),
    );
  }

  void _removeBillItem(int index) {
    setState(() {
      _billItems.removeAt(index);
    });
  }

  double get _subtotal => _billItems.fold(0, (sum, item) => sum + item.totalPrice);
  double get _tax => _subtotal * AppConstants.defaultTaxRate;
  double get _discount => double.tryParse(_discountController.text) ?? 0;
  double get _totalAmount => _subtotal + _tax - _discount;

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;
    if (_billItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item to the bill')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bill = Bill(
        id: _isEditing ? widget.bill!.id : null,
        billNumber: _isEditing ? widget.bill!.billNumber : BillCalculator.generateBillNumber(),
        shopId: widget.shop.id!,
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        customerAddress: _customerAddressController.text.trim(),
        items: _billItems,
        subtotal: _subtotal,
        tax: _tax,
        discount: _discount,
        totalAmount: _totalAmount,
        status: _billStatus,
        paymentMethod: _paymentMethod,
        createdDate: _isEditing ? widget.bill!.createdDate : DateTime.now(),
        dueDate: _dueDate,
        paidDate: _billStatus == BillStatus.paid ? DateTime.now() : null,
      );

      Bill savedBill;
      if (_isEditing) {
        await DBService.updateBill(widget.bill!.id!, bill);
        savedBill = bill;
      } else {
        savedBill = await DBService.addBill(bill);
      }

      if (mounted) {
        Navigator.pop(context, savedBill);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Bill updated successfully!' : 'Bill created successfully!'),
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
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFFFF9800)),
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
            borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBillItemCard(BillItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.quantity} × ₹${item.unitPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => _removeBillItem(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Subtotal', '₹${_subtotal.toStringAsFixed(2)}'),
            _buildSummaryRow('Tax (${(AppConstants.defaultTaxRate * 100).toInt()}%)', '₹${_tax.toStringAsFixed(2)}'),
            _buildSummaryRow('Discount', '₹${_discount.toStringAsFixed(2)}'),
            const Divider(),
            _buildSummaryRow(
              'Total Amount',
              '₹${_totalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? const Color(0xFFFF9800) : Colors.black87,
            ),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_isEditing ? 'Edit Bill' : 'Create Bill'),
            Text(
              widget.shop.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Information
                    const Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildFormField(
                      controller: _customerNameController,
                      label: 'Customer Name',
                      hint: 'Enter customer name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Customer name is required';
                        return null;
                      },
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            controller: _customerPhoneController,
                            label: 'Phone Number',
                            hint: '1234567890',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Phone is required';
                              if (value!.length < 10) return 'Invalid phone number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            controller: _discountController,
                            label: 'Discount',
                            hint: '0.00',
                            icon: Icons.discount,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            validator: (value) {
                              final discount = double.tryParse(value ?? '0');
                              if (discount == null || discount < 0) return 'Invalid discount';
                              if (discount > _subtotal) return 'Discount cannot exceed subtotal';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    _buildFormField(
                      controller: _customerAddressController,
                      label: 'Customer Address',
                      hint: 'Enter customer address',
                      icon: Icons.location_on,
                      maxLines: 2,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Address is required';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Bill Items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bill Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addBillItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_billItems.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No items added yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap "Add Item" to start building the bill',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...List.generate(
                        _billItems.length,
                            (index) => _buildBillItemCard(_billItems[index], index),
                      ),

                    if (_billItems.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSummaryCard(),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    _isEditing ? 'Update Bill' : 'Create Bill',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSelectionModal extends StatefulWidget {
  final List<Product> products;
  final Function(Product, int) onProductSelected;

  const _ProductSelectionModal({
    required this.products,
    required this.onProductSelected,
  });

  @override
  State<_ProductSelectionModal> createState() => _ProductSelectionModalState();
}

class _ProductSelectionModalState extends State<_ProductSelectionModal> {
  Product? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_shopping_cart, color: Color(0xFFFF9800)),
              const SizedBox(width: 12),
              const Text(
                'Add Product to Bill',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<Product>(
            value: _selectedProduct,
            hint: const Text('Select a product'),
            onChanged: (product) => setState(() => _selectedProduct = product),
            decoration: InputDecoration(
              labelText: 'Product',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.inventory, color: Color(0xFFFF9800)),
            ),
            items: widget.products
                .map((product) => DropdownMenuItem(
              value: product,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name),
                  Text(
                    '₹${product.sellPrice.toStringAsFixed(2)} • Stock: ${product.availableStock}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.numbers, color: Color(0xFFFF9800)),
            ),
            validator: (value) {
              final quantity = int.tryParse(value ?? '');
              if (quantity == null || quantity <= 0) return 'Invalid quantity';
              if (_selectedProduct != null && quantity > _selectedProduct!.availableStock) {
                return 'Quantity exceeds available stock (${_selectedProduct!.availableStock})';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedProduct != null) {
                  final quantity = int.tryParse(_quantityController.text) ?? 1;
                  if (quantity > 0 && quantity <= _selectedProduct!.availableStock) {
                    widget.onProductSelected(_selectedProduct!, quantity);
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add to Bill',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}