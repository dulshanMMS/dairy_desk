import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/product.dart';
import '../../services/db_service.dart';
import 'dairy_form_page.dart';

class DairyDetailPage extends StatefulWidget {
  final Product product;

  const DairyDetailPage({super.key, required this.product});

  @override
  State<DairyDetailPage> createState() => _DairyDetailPageState();
}

class _DairyDetailPageState extends State<DairyDetailPage> {
  late Product product;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    product = widget.product;
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
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

    if (confirm == true && product.id != null) {
      try {
        setState(() => isLoading = true);
        await DBService.deleteDairyProduct(product.id!);
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted successfully!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting product: $e')),
          );
        }
      }
    }
  }

  Future<void> _editProduct() async {
    final updatedProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) => DairyFormPage(product: product),
      ),
    );

    if (updatedProduct != null) {
      setState(() {
        product = updatedProduct;
      });
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profitColor = product.profit >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    final profitText = product.profit >= 0 ? 'Profit' : 'Loss';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _editProduct,
            icon: const Icon(Icons.edit),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteProduct();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Product'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_drink,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Added on ${_formatDate(product.date)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

            const SizedBox(height: 20),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Available Stock',
                    '${product.availableStock}',
                    Icons.inventory,
                    const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Returns',
                    '${product.returns}',
                    Icons.keyboard_return,
                    const Color(0xFFFF9800),
                  ),
                ),
              ],
            ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideX(begin: 0.2),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    profitText,
                    '₹${product.profit.toStringAsFixed(2)}',
                    Icons.trending_up,
                    profitColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Revenue',
                    '₹${product.totalRevenue.toStringAsFixed(2)}',
                    Icons.attach_money,
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ).animate(delay: 400.ms).fadeIn(duration: 600.ms).slideX(begin: -0.2),

            const SizedBox(height: 20),

            // Product Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Product Name', product.name, icon: Icons.local_drink),
                  _buildInfoRow('Category', product.category.toUpperCase(), icon: Icons.category),
                  _buildInfoRow('Total Stock', '${product.stock} units', icon: Icons.inventory_2),
                  _buildInfoRow('Returns', '${product.returns} units', icon: Icons.keyboard_return),
                  _buildInfoRow('Available Stock', '${product.availableStock} units', icon: Icons.check_circle),
                ],
              ),
            ).animate(delay: 600.ms).fadeIn(duration: 600.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            // Pricing Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pricing Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Buy Price', '₹${product.buyPrice.toStringAsFixed(2)} per unit', icon: Icons.shopping_cart),
                  _buildInfoRow('Sell Price', '₹${product.sellPrice.toStringAsFixed(2)} per unit', icon: Icons.sell),
                  _buildInfoRow('Price Margin', '₹${(product.sellPrice - product.buyPrice).toStringAsFixed(2)} per unit', icon: Icons.trending_up),
                  _buildInfoRow('Total Investment', '₹${product.totalInvestment.toStringAsFixed(2)}', icon: Icons.account_balance_wallet),
                  _buildInfoRow('Expected Revenue', '₹${product.totalRevenue.toStringAsFixed(2)}', icon: Icons.monetization_on),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Net $profitText',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '₹${product.profit.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: profitColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 800.ms).fadeIn(duration: 600.ms).slideY(begin: 0.2),

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _editProduct,
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('Edit Product'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}