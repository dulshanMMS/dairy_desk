import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/db_service.dart';
import '../../models/farm_item.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/search_bar.dart';
import '../../utils/formatters.dart';
import 'farm_form_page.dart';
import 'farm_detail_page.dart';

class FarmListPage extends StatefulWidget {
  const FarmListPage({super.key});

  @override
  State<FarmListPage> createState() => _FarmListPageState();
}

class _FarmListPageState extends State<FarmListPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<FarmItem> _allItems = [];
  List<FarmItem> _crops = [];
  List<FarmItem> _livestock = [];
  List<FarmItem> _spices = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFarmItems();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFarmItems() async {
    setState(() => isLoading = true);
    try {
      final items = await DBService.getFarmItems();
      setState(() {
        _allItems = items;
        _filterItems();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading farm items: $e')),
        );
      }
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    final filteredItems = _allItems.where((item) =>
        item.name.toLowerCase().contains(query)
    ).toList();

    setState(() {
      _crops = filteredItems.where((item) => item.type == FarmItemType.crop).toList();
      _livestock = filteredItems.where((item) => item.type == FarmItemType.livestock).toList();
      _spices = filteredItems.where((item) => item.type == FarmItemType.spice).toList();
    });
  }

  void _navigateToForm([FarmItem? item]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmFormPage(farmItem: item),
      ),
    );
    
    if (result == true) {
      _loadFarmItems();
    }
  }

  void _navigateToDetails(FarmItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmDetailPage(farmItem: item),
      ),
    );
  }

  Widget _buildFarmItemCard(FarmItem item, int index) {
    final profit = item.expectedProfit;
    final profitColor = profit >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    return CustomCard(
      onTap: () => _navigateToDetails(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.type.toString().split('.').last.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: item.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(item.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(item.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (item.area != null) ...[
            Row(
              children: [
                const Icon(Icons.landscape, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Area: ${item.area}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Investment',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(item.investment),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expected',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(item.expectedRevenue),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Profit',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(profit),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: profitColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.3, duration: 400.ms)
        .fadeIn(duration: 400.ms);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'growing':
      case 'good':
        return const Color(0xFF4CAF50);
      case 'ready':
      case 'harvest':
        return const Color(0xFFFF9800);
      case 'inactive':
      case 'sold':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF2196F3);
    }
  }

  Widget _buildTabView(List<FarmItem> items, String emptyMessage) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.agriculture_outlined,
                size: 64,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add your first item to get started",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildFarmItemCard(items[index], index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Farm Management'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadFarmItems,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Crops'),
            Tab(text: 'Livestock'),
            Tab(text: 'Spices'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            )
          : Column(
              children: [
                CustomSearchBar(
                  hintText: "Search farm items...",
                  controller: _searchController,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabView(_crops, "No crops yet"),
                      _buildTabView(_livestock, "No livestock yet"),
                      _buildTabView(_spices, "No spices yet"),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
      ),
    );
  }
}
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: crop['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    crop['icon'],
                    color: crop['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Area: ${crop['area']}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(crop['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    crop['status'],
                    style: TextStyle(
                      color: _getStatusColor(crop['status']),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    "Planted",
                    _formatDate(crop['planted']),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    "Harvest",
                    _formatDate(crop['expectedHarvest']),
                    Icons.schedule,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Investment",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        "₹${crop['investment'].toString()}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Expected Profit",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        "₹${profit.toString()}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: profitColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
        .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 400.ms);
  }

  Widget _buildLivestockCard(Map<String, dynamic> livestock, int index) {
    final profit = livestock['revenue'] - livestock['feedCost'];
    final profitColor = profit >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: livestock['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    livestock['icon'],
                    color: livestock['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            livestock['type'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: livestock['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${livestock['count']}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: livestock['color'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${livestock['breed']} • ${livestock['age']}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getHealthStatusColor(livestock['healthStatus']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    livestock['healthStatus'],
                    style: TextStyle(
                      color: _getHealthStatusColor(livestock['healthStatus']),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Monthly Yield",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        livestock['monthlyYield'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Feed Cost",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "₹${livestock['feedCost'].toString()}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Monthly Profit",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "₹${profit.toString()}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: profitColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
        .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 400.ms);
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'growing':
        return const Color(0xFF4CAF50);
      case 'ready':
        return const Color(0xFFFF9800);
      case 'harvested':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return const Color(0xFF4CAF50);
      case 'good':
        return const Color(0xFF8BC34A);
      case 'fair':
        return const Color(0xFFFF9800);
      case 'poor':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Farm Management'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.eco),
              text: 'Crops',
            ),
            Tab(
              icon: Icon(Icons.pets),
              text: 'Livestock',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Crops Tab
          _crops.isEmpty
              ? _buildEmptyState(
            "No crops planted yet",
            "Add your first crop to start farming",
            Icons.eco,
            const Color(0xFF4CAF50),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _crops.length,
            itemBuilder: (context, index) => _buildCropCard(_crops[index], index),
          ),

          // Livestock Tab
          _livestock.isEmpty
              ? _buildEmptyState(
            "No livestock yet",
            "Add animals to your farm inventory",
            Icons.pets,
            const Color(0xFF2196F3),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _livestock.length,
            itemBuilder: (context, index) => _buildLivestockCard(_livestock[index], index),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement add functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add functionality coming soon!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? "Add Crop" : "Add Livestock"),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate()
        .scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 600.ms);
  }
}