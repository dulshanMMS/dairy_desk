import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_session.dart';
import '../models/product_master.dart';
import '../services/db_service.dart';
import '../services/daily_session_service.dart';

class DailySessionEntryPage extends StatefulWidget {
  final String businessType; // 'dairy', 'farm', or 'shop'
  final String title;
  final Color themeColor;

  const DailySessionEntryPage({
    super.key,
    required this.businessType,
    required this.title,
    required this.themeColor,
  });

  @override
  State<DailySessionEntryPage> createState() => _DailySessionEntryPageState();
}

class _DailySessionEntryPageState extends State<DailySessionEntryPage> {
  DailySession? _todaySession;
  List<ProductMaster> _availableProducts = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load today's session
      final session = await DailySessionService.getTodaySession(widget.businessType);

      // Load available products for this category
      final products = await DBService.getProductMasters(category: widget.businessType);

      setState(() {
        _todaySession = session;
        _availableProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _showAddProductDialog() async {
    if (_availableProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No products available. Please add products in Product Master first.'),
        ),
      );
      return;
    }

    ProductMaster? selectedProduct;
    final sentController = TextEditingController();
    final returnController = TextEditingController(text: '0');
    final soldController = TextEditingController(text: '0');
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Product Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Selector
                DropdownButtonFormField<ProductMaster>(
                  value: selectedProduct,
                  decoration: const InputDecoration(
                    labelText: 'Select Product',
                    prefixIcon: Icon(Icons.inventory),
                    border: OutlineInputBorder(),
                  ),
                  items: _availableProducts.map((product) {
                    return DropdownMenuItem(
                      value: product,
                      child: Text('${product.name} (LKR ${product.sellPrice})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedProduct = value);
                  },
                ),
                const SizedBox(height: 16),
                // Sent Count
                TextField(
                  controller: sentController,
                  decoration: const InputDecoration(
                    labelText: 'Sent/Available Quantity',
                    prefixIcon: Icon(Icons.send),
                    border: OutlineInputBorder(),
                    helperText: 'Items sent out or available at start of day',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // Return Count
                TextField(
                  controller: returnController,
                  decoration: const InputDecoration(
                    labelText: 'Returned Quantity',
                    prefixIcon: Icon(Icons.keyboard_return),
                    border: OutlineInputBorder(),
                    helperText: 'Items returned at end of day',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // Sold Count
                TextField(
                  controller: soldController,
                  decoration: const InputDecoration(
                    labelText: 'Sold Quantity',
                    prefixIcon: Icon(Icons.shopping_cart),
                    border: OutlineInputBorder(),
                    helperText: 'Items actually sold',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // Notes
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedProduct == null || sentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a product and enter quantity')),
                  );
                  return;
                }

                try {
                  final entry = DailyProductEntry(
                    productId: selectedProduct!.id!,
                    productName: selectedProduct!.name,
                    sentCount: int.parse(sentController.text),
                    returnCount: int.parse(returnController.text),
                    soldCount: int.parse(soldController.text),
                    buyPrice: selectedProduct!.buyPrice,
                    sellPrice: selectedProduct!.sellPrice,
                    notes: notesController.text.isNotEmpty ? notesController.text : null,
                  );

                  await DailySessionService.addProductEntry(widget.businessType, entry);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product entry added successfully')),
                    );
                    _loadData();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditProductDialog(DailyProductEntry entry) async {
    final sentController = TextEditingController(text: entry.sentCount.toString());
    final returnController = TextEditingController(text: entry.returnCount.toString());
    final soldController = TextEditingController(text: entry.soldCount.toString());
    final notesController = TextEditingController(text: entry.notes ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${entry.productName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sentController,
                decoration: const InputDecoration(
                  labelText: 'Sent/Available Quantity',
                  prefixIcon: Icon(Icons.send),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: returnController,
                decoration: const InputDecoration(
                  labelText: 'Returned Quantity',
                  prefixIcon: Icon(Icons.keyboard_return),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: soldController,
                decoration: const InputDecoration(
                  labelText: 'Sold Quantity',
                  prefixIcon: Icon(Icons.shopping_cart),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final updatedEntry = entry.copyWith(
                  sentCount: int.parse(sentController.text),
                  returnCount: int.parse(returnController.text),
                  soldCount: int.parse(soldController.text),
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                );

                await DailySessionService.addProductEntry(widget.businessType, updatedEntry);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Entry updated successfully')),
                  );
                  _loadData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEntry(DailyProductEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Remove ${entry.productName} from today\'s session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DailySessionService.removeProductEntry(
          widget.businessType,
          entry.productId,
          entry.shopId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entry deleted successfully')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Widget _buildProductEntryCard(DailyProductEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: widget.themeColor,
          child: const Icon(Icons.inventory, color: Colors.white),
        ),
        title: Text(
          entry.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Sent: ${entry.sentCount} • Returned: ${entry.returnCount} • Sold: ${entry.soldCount}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LKR ${entry.totalRevenue.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoChip('Buy Price', 'LKR ${entry.buyPrice}', Colors.orange),
                    _buildInfoChip('Sell Price', 'LKR ${entry.sellPrice}', Colors.blue),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoChip('Revenue', 'LKR ${entry.totalRevenue.toStringAsFixed(2)}', Colors.green),
                    _buildInfoChip('Profit', 'LKR ${entry.profit.toStringAsFixed(2)}', Colors.purple),
                  ],
                ),
                if (entry.notes != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.notes!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditProductDialog(entry),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deleteEntry(entry),
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_todaySession == null || _todaySession!.products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.themeColor, widget.themeColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Sent', _todaySession!.totalItemsSent.toString(), Icons.send),
                _buildSummaryItem('Returned', _todaySession!.totalItemsReturned.toString(), Icons.keyboard_return),
                _buildSummaryItem('Sold', _todaySession!.totalItemsSold.toString(), Icons.shopping_cart),
              ],
            ),
            const Divider(color: Colors.white54, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Revenue', 'LKR ${_todaySession!.totalRevenue.toStringAsFixed(0)}', Icons.attach_money),
                _buildSummaryItem('Profit', 'LKR ${_todaySession!.profit.toStringAsFixed(0)}', Icons.trending_up),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            Text(
              DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: widget.themeColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _todaySession == null || _todaySession!.products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No entries for today',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your first product entry',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        _buildSummaryCard(),
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Product Entries',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ..._todaySession!.products.map(_buildProductEntryCard),
                        const SizedBox(height: 80), // Space for FAB
                      ],
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        backgroundColor: widget.themeColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }
}

