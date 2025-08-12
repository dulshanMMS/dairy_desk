import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/shop.dart';
import '../../services/db_service.dart';
import '../../config/constants.dart';

class ShopFormPage extends StatefulWidget {
  final Shop? shop; // null for create, non-null for edit

  const ShopFormPage({super.key, this.shop});

  @override
  State<ShopFormPage> createState() => _ShopFormPageState();
}

class _ShopFormPageState extends State<ShopFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  bool get _isEditing => widget.shop != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final shop = widget.shop!;
    _nameController.text = shop.name;
    _ownerNameController.text = shop.ownerName;
    _phoneController.text = shop.phone;
    _emailController.text = shop.email;
    _addressController.text = shop.address;
    _isActive = shop.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveShop() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final shop = Shop(
        id: _isEditing ? widget.shop!.id : null,
        name: _nameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        isActive: _isActive,
        createdDate: _isEditing ? widget.shop!.createdDate : DateTime.now(),
        settings: _isEditing ? widget.shop!.settings : {},
      );

      Shop savedShop;
      if (_isEditing) {
        await DBService.updateShop(widget.shop!.id!, shop);
        savedShop = shop;
      } else {
        savedShop = await DBService.addShop(shop);
      }

      if (mounted) {
        Navigator.pop(context, savedShop);
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
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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

  Widget _buildStatusSwitch() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.store,
            color: _isActive ? const Color(0xFF4CAF50) : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shop Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  _isActive ? 'Shop is active and operational' : 'Shop is temporarily closed',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
            activeColor: const Color(0xFF4CAF50),
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
        title: Text(_isEditing ? 'Edit Shop' : 'Add New Shop'),
        backgroundColor: const Color(0xFFFF9800),
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
                    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.store,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isEditing ? 'Update Shop Information' : 'Register New Shop',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEditing
                          ? 'Modify the shop details below'
                          : 'Fill in the shop details to get started with billing',
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
                label: 'Shop Name',
                hint: 'e.g., Green Valley Store',
                icon: Icons.store,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Shop name is required';
                  if (value!.length < AppConstants.minNameLength) return 'Name too short';
                  if (value.length > AppConstants.maxNameLength) return 'Name too long';
                  return null;
                },
              ),

              _buildFormField(
                controller: _ownerNameController,
                label: 'Owner Name',
                hint: 'e.g., John Doe',
                icon: Icons.person,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Owner name is required';
                  if (value!.length < AppConstants.minNameLength) return 'Name too short';
                  if (value.length > AppConstants.maxNameLength) return 'Name too long';
                  return null;
                },
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '1234567890',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Phone number is required';
                        if (value!.length < AppConstants.minPhoneLength) return 'Phone number too short';
                        if (value.length > AppConstants.maxPhoneLength) return 'Phone number too long';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'shop@example.com',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Email is required';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              _buildFormField(
                controller: _addressController,
                label: 'Shop Address',
                hint: 'Enter complete address with city and postal code',
                icon: Icons.location_on,
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Address is required';
                  if (value!.length < 10) return 'Please enter a complete address';
                  return null;
                },
              ),

              _buildStatusSwitch(),

              const SizedBox(height: 20),

              // Additional Information Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Important Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• This shop will be used for creating bills and invoices\n'
                          '• Make sure all contact details are accurate\n'
                          '• You can manage shop status anytime after creation\n'
                          '• Shop information will appear on generated bills',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveShop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
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
                    _isEditing ? 'Update Shop' : 'Save Shop',
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