import 'package:flutter/material.dart';
import '../../models/farm_item.dart';
import '../../services/db_service.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

class FarmFormPage extends StatefulWidget {
  final FarmItem? farmItem;

  const FarmFormPage({super.key, this.farmItem});

  @override
  State<FarmFormPage> createState() => _FarmFormPageState();
}

class _FarmFormPageState extends State<FarmFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _investmentController = TextEditingController();
  final _expectedRevenueController = TextEditingController();
  final _statusController = TextEditingController();
  
  FarmItemType _selectedType = FarmItemType.crop;
  DateTime? _plantedDate;
  DateTime? _expectedHarvestDate;
  bool _isLoading = false;
  
  bool get _isEditing => widget.farmItem != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.farmItem!.name;
      _areaController.text = widget.farmItem!.area ?? '';
      _investmentController.text = widget.farmItem!.investment.toString();
      _expectedRevenueController.text = widget.farmItem!.expectedRevenue.toString();
      _statusController.text = widget.farmItem!.status;
      _selectedType = widget.farmItem!.type;
      _plantedDate = widget.farmItem!.plantedDate;
      _expectedHarvestDate = widget.farmItem!.expectedHarvestDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _investmentController.dispose();
    _expectedRevenueController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isPlanted) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPlanted ? _plantedDate ?? DateTime.now() : _expectedHarvestDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        if (isPlanted) {
          _plantedDate = picked;
        } else {
          _expectedHarvestDate = picked;
        }
      });
    }
  }

  Future<void> _saveFarmItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final farmItem = FarmItem(
        id: widget.farmItem?.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        area: _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
        investment: double.parse(_investmentController.text.trim()),
        expectedRevenue: double.parse(_expectedRevenueController.text.trim()),
        status: _statusController.text.trim().isEmpty ? 'Active' : _statusController.text.trim(),
        plantedDate: _plantedDate,
        expectedHarvestDate: _expectedHarvestDate,
        icon: _getIconForType(_selectedType),
        color: _getColorForType(_selectedType),
        date: widget.farmItem?.date,
      );

      if (_isEditing) {
        await DBService.updateFarmItem(farmItem);
      } else {
        await DBService.addFarmItem(farmItem);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Farm item ${_isEditing ? 'updated' : 'added'} successfully!'),
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

  IconData _getIconForType(FarmItemType type) {
    switch (type) {
      case FarmItemType.crop:
        return Icons.grass;
      case FarmItemType.livestock:
        return Icons.pets;
      case FarmItemType.spice:
        return Icons.eco;
    }
  }

  Color _getColorForType(FarmItemType type) {
    switch (type) {
      case FarmItemType.crop:
        return const Color(0xFF4CAF50);
      case FarmItemType.livestock:
        return const Color(0xFF2196F3);
      case FarmItemType.spice:
        return const Color(0xFFFF9800);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_isEditing ? 'Edit' : 'Add'} Farm Item'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomInputField(
              label: 'Item Name',
              controller: _nameController,
              isRequired: true,
              prefixIcon: Icons.agriculture,
              validator: (value) => Validators.validateRequired(value, 'Item name'),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...FarmItemType.values.map((type) {
                      return RadioListTile<FarmItemType>(
                        title: Row(
                          children: [
                            Icon(_getIconForType(type), color: _getColorForType(type)),
                            const SizedBox(width: 8),
                            Text(type.toString().split('.').last.toUpperCase()),
                          ],
                        ),
                        value: type,
                        groupValue: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            if (_selectedType == FarmItemType.crop) ...[
              CustomInputField(
                label: 'Area',
                controller: _areaController,
                hint: 'e.g., 5.5 acres',
                prefixIcon: Icons.landscape,
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Planted Date'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDate(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16),
                                        const SizedBox(width: 8),
                                        Text(_plantedDate?.toString().split(' ')[0] ?? 'Select Date'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Harvest Date'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDate(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _expectedHarvestDate?.toString().split(' ')[0] ?? 'Select Date',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    label: 'Investment (₹)',
                    controller: _investmentController,
                    isRequired: true,
                    prefixIcon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.validatePositiveNumber(value, 'Investment'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomInputField(
                    label: 'Expected Revenue (₹)',
                    controller: _expectedRevenueController,
                    isRequired: true,
                    prefixIcon: Icons.trending_up,
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.validatePositiveNumber(value, 'Expected revenue'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            CustomInputField(
              label: 'Status',
              controller: _statusController,
              hint: 'e.g., Active, Growing, Ready',
              prefixIcon: Icons.info,
            ),
            const SizedBox(height: 32),
            
            CustomButton(
              text: _isEditing ? 'Update Item' : 'Add Item',
              onPressed: _saveFarmItem,
              isLoading: _isLoading,
              backgroundColor: const Color(0xFF4CAF50),
              icon: _isEditing ? Icons.update : Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}
