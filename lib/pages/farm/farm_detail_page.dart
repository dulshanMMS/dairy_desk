import 'package:flutter/material.dart';
import '../../models/farm_item.dart';
import '../../utils/formatters.dart';
import 'farm_form_page.dart';

class FarmDetailPage extends StatelessWidget {
  final FarmItem farmItem;

  const FarmDetailPage({super.key, required this.farmItem});

  @override
  Widget build(BuildContext context) {
    final profit = farmItem.expectedProfit;
    final profitColor = profit >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    return Scaffold(
      appBar: AppBar(
        title: Text(farmItem.name),
        backgroundColor: farmItem.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FarmFormPage(farmItem: farmItem),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: farmItem.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        farmItem.icon,
                        size: 48,
                        color: farmItem.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      farmItem.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: farmItem.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        farmItem.type.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          color: farmItem.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financial Overview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFinancialItem(
                            'Investment',
                            Formatters.formatCurrency(farmItem.investment),
                            Icons.arrow_downward,
                            Colors.red,
                          ),
                        ),
                        Expanded(
                          child: _buildFinancialItem(
                            'Expected Revenue',
                            Formatters.formatCurrency(farmItem.expectedRevenue),
                            Icons.arrow_upward,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          profit >= 0 ? Icons.trending_up : Icons.trending_down,
                          color: profitColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Expected Profit: ${Formatters.formatCurrency(profit)}',
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
              ),
            ),
            const SizedBox(height: 16),

            // Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDetailRow('Status', farmItem.status),
                    
                    if (farmItem.area != null)
                      _buildDetailRow('Area', farmItem.area!),
                    
                    if (farmItem.plantedDate != null)
                      _buildDetailRow(
                        'Planted Date',
                        Formatters.formatDate(farmItem.plantedDate!),
                      ),
                    
                    if (farmItem.expectedHarvestDate != null)
                      _buildDetailRow(
                        'Expected Harvest',
                        Formatters.formatDate(farmItem.expectedHarvestDate!),
                      ),
                    
                    _buildDetailRow(
                      'Added Date',
                      Formatters.formatDate(farmItem.date),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Progress Card (for crops)
            if (farmItem.type == FarmItemType.crop && 
                farmItem.plantedDate != null && 
                farmItem.expectedHarvestDate != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Growth Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProgressIndicator(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    if (farmItem.plantedDate == null || farmItem.expectedHarvestDate == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final totalDays = farmItem.expectedHarvestDate!.difference(farmItem.plantedDate!).inDays;
    final elapsedDays = now.difference(farmItem.plantedDate!).inDays;
    final progress = (elapsedDays / totalDays).clamp(0.0, 1.0);

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(farmItem.color),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).toInt()}% Complete',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${totalDays - elapsedDays} days remaining',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
