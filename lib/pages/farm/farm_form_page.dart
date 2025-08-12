import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/farm_item.dart';
import '../../services/db_service.dart';
import '../../config/constants.dart';

class FarmFormPage extends StatefulWidget {
  final FarmItem? farmItem; // null for create, non-null for edit

  const FarmFormPage({super.key, this.farmItem});

  @override
  State<FarmFormPage> createState() => _FarmFormPageState();
}

class _FarmFormPageState extends State<FarmFormPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Common fields
  final _nameController = TextEditingController();

  // Crop fields
  final _areaController = TextEditingController();
  final _investmentController = TextEditingController();
  final _expectedRevenueController = TextEditingController();
  DateTime _plantedDate = DateTime.now();
  DateTime _expectedHarvestDate = DateTime.now().add(const Duration(days: 120));
  CropStatus _cropStatus = CropStatus.planted;

  // Livestock fields
  final _countController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _monthlyYieldController = TextEditingController();
  final _feedCostController = TextEditingController();
  final _revenueController = TextEditingController();
  LivestockHealthStatus _healthStatus = LivestockHealthStatus.good;

  FarmItemType _selectedType = FarmItemType.crop;
  bool _isLoading = false;
  bool get _isEditing => widget.farmItem != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (_isEditing) {
      _populateFields();
    }

    _tabController.addListener(() {
      setState(() {
        _selectedType = _tabController.index == 0 ? FarmItemType.crop : FarmItemType.livestock;
      });
    });
  }

  void _populateFields() {
    final farmItem = widget.farmItem!;
    _nameController.text = farmItem.name;
    _selectedType = farmItem.type;
    _tabController.index = farmItem.type == FarmItemType.crop ? 0 : 1;

    if (farmItem.type == FarmItemType.crop) {
      _areaController.text = farmItem.area ?? '';
      _investmentController.text = farmItem.investment?.toString() ?? '';
      _expectedRevenueController.text = farmItem.expectedRevenue?.toString() ?? '';
      _plantedDate = farmItem.plantedDate ?? DateTime.now();
      _expectedHarvestDate = farmItem.expectedHarvestDate ?? DateTime.now().add(const Duration(days: 120));
      _cropStatus = farmItem.cropStatus ?? CropStatus.planted;
    } else {
      _countController.text = farmItem.count?.toString() ?? '';
      _breedController.text = farmItem.breed ?? '';
      _ageController.text = farmItem.age ?? '';
      _monthlyYieldController.text = farmItem.monthlyYield ?? '';
      _feedCostController.text = farmItem.feedCost?.toString() ?? '';
      _revenueController.text = farmItem.revenue?.toString() ?? '';
      _healthStatus = farmItem.healthStatus ?? LivestockHealthStatus.good;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _areaController.dispose();
    _investmentController.dispose();
    _expectedRevenueController.dispose();
    _countController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _monthlyYieldController.dispose();
    _feedCostController.dispose();
    _revenueController.dispose();
    super.dispose();
  }

  Future<void> _saveFarmItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      FarmItem farmItem;

      if (_selectedType == FarmItemType.crop) {
        farmItem = FarmItemFactory.createCrop(
          name: _nameController.text.trim(),
          area: _areaController.text.trim(),
          plantedDate: _plantedDate,
          expectedHarvestDate: _expectedHarvestDate,
          investment: double.parse(_investmentController.text),
          expectedRevenue: double.parse(_expectedRevenueController.text),
          status: _cropStatus,
        );
      } else {
        farmItem = FarmItemFactory.createLivestock(
          name: _nameController.text.trim(),
          count: int.parse(_countController.text),
          breed: _breedController.text.trim(),
          age: _ageController.text.trim(),
          monthlyYield: _monthlyYieldController.text.trim(),
          feedCost: double.parse(_feedCostController.text),
          revenue: double.parse(_revenueController.text),
          healthStatus: _healthStatus,
        );
      }

      if (_isEditing) {
        farmItem = farmItem.copyWith(
          id: widget.farmItem!.id,
          createdDate: widget.farmItem!.createdDate,
          lastUpdated: DateTime.now(),
        );
        await DBService.updateFarmItem(widget.farmItem!.id!, farmItem);
      } else {
        farmItem = await DBService.addFarmItem(farmItem);
      }

      if (mounted) {
        Navigator.pop(context, farmItem);
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
    int maxLines = 1,
  }) {
    final primaryColor = _selectedType == FarmItemType.crop
        ? const Color(0xFF4CAF50)
        : const Color(0xFF2196F3);

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
          suffixText: suffix,
          prefixIcon: Icon(icon, color: primaryColor),
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
            borderSide: BorderSide(color: primaryColor, width: 2),
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

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required Function(DateTime) onChanged,
    required IconData icon,
  }) {
    final primaryColor = _selectedType == FarmItemType.crop
        ? const Color(0xFF4CAF50)
        : const Color(0xFF2196F3);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (picked != null) {
            onChanged(picked);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: primaryColor),
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
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          child: Text(
            "${date.day}/${date.month}/${date.year}",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCropForm() {
    final investment = double.tryParse(_investmentController.text) ?? 0;
    final expectedRevenue = double.tryParse(_expectedRevenueController.text) ?? 0;
    final profit = expectedRevenue - investment;
    final profitColor = profit >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
          _buildFormField(
          controller: _nameController,
          label: 'Crop Name',
          hint: 'e.g., Rice, Wheat, Corn',
          icon: Icons.eco,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Crop name is required';
            return null;
          },
        ),

        _buildFormField(
            controller: _areaController,
            label: 'Area',
            hint: 'e.g., 5.5 acres',
            icon: Icons.landscape,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Area is required';
              return null;
            },
        ),

            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Planted Date',
                    date: _plantedDate,
                    onChanged: (date) => setState(() => _plantedDate = date),
                    icon: Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    label: 'Expected Harvest',
                    date: _expectedHarvestDate,
                    onChanged: (date) => setState(() => _expectedHarvestDate = date),
                    icon: Icons.schedule,
                  ),
                ),
              ],
            ),

            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: DropdownButtonFormField<CropStatus>(
                value: _cropStatus,
                onChanged: (value) => setState(() => _cropStatus = value!),
                decoration: InputDecoration(
                  labelText: 'Crop Status',
                  prefixIcon: const Icon(Icons.flag, color: Color(0xFF4CAF50)),
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
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: CropStatus.values
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.toString().split('.').last.toUpperCase()),
                ))
                    .toList(),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    controller: _investmentController,
                    label: 'Investment',
                    hint: '0.00',
                    icon: Icons.account_balance_wallet,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    suffix: '₹',
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      final amount = double.tryParse(value!);
                      if (amount == null) return 'Invalid amount';
                      if (amount < 0) return 'Cannot be negative';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFormField(
                    controller: _expectedRevenueController,
                    label: 'Expected Revenue',
                    hint: '0.00',
                    icon: Icons.monetization_on,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    suffix: '₹',
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      final amount = double.tryParse(value!);
                      if (amount == null) return 'Invalid amount';
                      if (amount < 0) return 'Cannot be negative';
                      return null;
                    },
                  ),
                ),
              ],
            ),

            // Profit Preview
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: profitColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: profitColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expected Profit:',
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
            ),
          ],
        ),
    );
  }

  Widget _buildLivestockForm() {
    final feedCost = double.tryParse(_feedCostController.text) ?? 0;
    final revenue = double.tryParse(_revenueController.text) ?? 0;
    final profit = revenue - feedCost;
    final profitColor = profit >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFormField(
            controller: _nameController,
            label: 'Animal Type',
            hint: 'e.g., Cows, Goats, Chickens',
            icon: Icons.pets,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Animal type is required';
              return null;
            },
          ),

          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: _countController,
                  label: 'Count',
                  hint: '0',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  suffix: 'animals',
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final count = int.tryParse(value!);
                    if (count == null) return 'Invalid number';
                    if (count <= 0) return 'Must be greater than 0';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: _breedController,
                  label: 'Breed',
                  hint: 'e.g., Holstein, Boer',
                  icon: Icons.category,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Breed is required';
                    return null;
                  },
                ),
              ),
            ],
          ),

          _buildFormField(
            controller: _ageController,
            label: 'Age Range',
            hint: 'e.g., 2-4 years, 6 months',
            icon: Icons.calendar_today,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Age range is required';
              return null;
            },
          ),

          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: DropdownButtonFormField<LivestockHealthStatus>(
              value: _healthStatus,
              onChanged: (value) => setState(() => _healthStatus = value!),
              decoration: InputDecoration(
                labelText: 'Health Status',
                prefixIcon: const Icon(Icons.favorite, color: Color(0xFF2196F3)),
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
                  borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: LivestockHealthStatus.values
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status.toString().split('.').last.toUpperCase()),
              ))
                  .toList(),
            ),
          ),

          _buildFormField(
            controller: _monthlyYieldController,
            label: 'Monthly Yield',
            hint: 'e.g., 360 liters/day, 50 eggs/day',
            icon: Icons.water_drop,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Monthly yield is required';
              return null;
            },
          ),

          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: _feedCostController,
                  label: 'Monthly Feed Cost',
                  hint: '0.00',
                  icon: Icons.restaurant,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  suffix: '₹',
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final amount = double.tryParse(value!);
                    if (amount == null) return 'Invalid amount';
                    if (amount < 0) return 'Cannot be negative';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: _revenueController,
                  label: 'Monthly Revenue',
                  hint: '0.00',
                  icon: Icons.monetization_on,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  suffix: '₹',
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final amount = double.tryParse(value!);
                    if (amount == null) return 'Invalid amount';
                    if (amount < 0) return 'Cannot be negative';
                    return null;
                  },
                ),
              ),
            ],
          ),

          // Profit Preview
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: profitColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: profitColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Profit:',
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _selectedType == FarmItemType.crop
        ? const Color(0xFF4CAF50)
        : const Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Farm Item' : 'Add Farm Item'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: _isEditing ? null : TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.eco), text: 'Crop'),
            Tab(icon: Icon(Icons.pets), text: 'Livestock'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    _selectedType == FarmItemType.crop ? Icons.eco : Icons.pets,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isEditing
                        ? 'Update ${_selectedType == FarmItemType.crop ? 'Crop' : 'Livestock'} Details'
                        : 'Add New ${_selectedType == FarmItemType.crop ? 'Crop' : 'Livestock'}',
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
                        ? 'Modify the information below'
                        : 'Fill in the details to add to your farm',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: _isEditing
                  ? (_selectedType == FarmItemType.crop ? _buildCropForm() : _buildLivestockForm())
                  : TabBarView(
                controller: _tabController,
                children: [
                  _buildCropForm(),
                  _buildLivestockForm(),
                ],
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveFarmItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
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
                    _isEditing ? 'Update Item' : 'Save Item',
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