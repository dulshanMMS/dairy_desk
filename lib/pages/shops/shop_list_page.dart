import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/db_service.dart';
import '../../models/shop.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/search_bar.dart';
import 'shop_form_page.dart';
import 'bill_list_page.dart';

class ShopListPage extends StatefulWidget {
  const ShopListPage({super.key});

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  List<Shop> shops = [];
  List<Shop> filteredShops = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadShops();
    _searchController.addListener(_filterShops);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadShops() async {
    setState(() => isLoading = true);
    try {
      final loadedShops = await DBService.getShops();
      setState(() {
        shops = loadedShops;
        filteredShops = loadedShops;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading shops: $e')),
        );
      }
    }
  }

  void _filterShops() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredShops = shops.where((shop) =>
          shop.name.toLowerCase().contains(query) ||
          shop.ownerName.toLowerCase().contains(query)
      ).toList();
    });
  }

  void _navigateToShopForm([Shop? shop]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopFormPage(shop: shop),
      ),
    );
    
    if (result == true) {
      _loadShops();
    }
  }

  void _navigateToBills(Shop shop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillListPage(shop: shop),
      ),
    );
  }

  Widget _buildShopCard(Shop shop, int index) {
    return CustomCard(
      onTap: () => _navigateToBills(shop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store,
                  color: Color(0xFFFF9800),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shop.ownerName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _navigateToShopForm(shop),
                icon: const Icon(Icons.edit, color: Colors.grey),
              ),
            ],
          ),
          if (shop.phone != null || shop.address != null) ...[
            const SizedBox(height: 12),
            if (shop.phone != null)
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    shop.phone!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            if (shop.address != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shop.address!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.3, duration: 400.ms)
        .fadeIn(duration: 400.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.store_outlined,
              size: 64,
              color: Color(0xFFFF9800),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No shops yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first shop to start billing",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToShopForm(),
            icon: const Icon(Icons.add),
            label: const Text("Add Shop"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
        title: const Text('Shop Billing'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadShops,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF9800),
              ),
            )
          : Column(
              children: [
                CustomSearchBar(
                  hintText: "Search shops...",
                  controller: _searchController,
                ),
                if (filteredShops.isEmpty && _searchController.text.isEmpty)
                  Expanded(child: _buildEmptyState())
                else if (filteredShops.isEmpty && _searchController.text.isNotEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No shops found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredShops.length,
                      itemBuilder: (context, index) =>
                          _buildShopCard(filteredShops[index], index),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToShopForm(),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Shop"),
      ),
    );
  }
}
