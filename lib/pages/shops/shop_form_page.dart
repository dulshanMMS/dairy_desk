import 'package:flutter/material.dart';
import '../../models/shop.dart';
import '../../services/db_service.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

class ShopFormPage extends StatefulWidget {
  final Shop? shop;

  const ShopFormPage({super.key, this.shop});

  @override
  State<ShopFormPage> createState() => _ShopFormPageState();
}

class _ShopFormPageState extends State<ShopFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool get _isEditing => widget.shop != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.shop!.name;
      _ownerController.text = widget.shop!.ownerName;
      _phoneController.text = widget.shop!.phone ?? '';
      _addressController.text = widget.shop!.address ?? '';
      _emailController.text = widget.shop!.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveShop() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final shop = Shop(
        id: widget.shop?.id,
        name: _nameController.text.trim(),
        ownerName: _ownerController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        createdDate: widget.shop?.createdDate,
      );

      if (_isEditing) {
        await DBService.updateShop(shop);
      } else {
        await DBService.addShop(shop);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shop ${_isEditing ? 'updated' : 'added'} successfully!'),
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
        title: Text('${_isEditing ? 'Edit' : 'Add'} Shop'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomInputField(
              label: 'Shop Name',
              controller: _nameController,
              isRequired: true,
              prefixIcon: Icons.store,
              validator: (value) => Validators.validateRequired(value, 'Shop name'),
            ),
            const SizedBox(height: 16),
            
            CustomInputField(
              label: 'Owner Name',
              controller: _ownerController,
              isRequired: true,
              prefixIcon: Icons.person,
              validator: (value) => Validators.validateRequired(value, 'Owner name'),
            ),
            const SizedBox(height: 16),
            
            CustomInputField(
              label: 'Phone Number',
              controller: _phoneController,
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  return Validators.validatePhone(value);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            CustomInputField(
              label: 'Email',
              controller: _emailController,
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  return Validators.validateEmail(value);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            CustomInputField(
              label: 'Address',
              controller: _addressController,
              prefixIcon: Icons.location_on,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            
            CustomButton(
              text: _isEditing ? 'Update Shop' : 'Add Shop',
              onPressed: _saveShop,
              isLoading: _isLoading,
              backgroundColor: const Color(0xFFFF9800),
              icon: _isEditing ? Icons.update : Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}
