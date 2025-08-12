import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/shop.dart';
import '../../models/bill.dart';
import '../../services/db_service.dart';
import '../../widgets/bill_status_chip.dart';
import '../../widgets/custom_card.dart';
import '../../utils/formatters.dart';
import 'bill_form_page.dart';

class BillListPage extends StatefulWidget {
  final Shop shop;

  const BillListPage({super.key, required this.shop});

  @override
  State<BillListPage> createState() => _BillListPageState();
}

class _BillListPageState extends State<BillListPage> {
  List<Bill> bills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => isLoading = true);
    try {
      final loadedBills = await DBService.getBillsByShop(widget.shop.id!);
      setState(() {
        bills = loadedBills;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bills: $e')),
        );
      }
    }
  }

  void _navigateToBillForm([Bill? bill]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillFormPage(shop: widget.shop, bill: bill),
      ),
    );
    
    if (result == true) {
      _loadBills();
    }
  }

  Future<void> _markAsPaid(Bill bill) async {
    try {
      await DBService.markBillAsPaid(bill.id!, PaymentMethod.cash);
      _loadBills();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill marked as paid'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildBillCard(Bill bill, int index) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill #${bill.id.toString().substring(18)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      Formatters.formatDate(bill.createdDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              BillStatusChip(status: bill.status),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${Formatters.formatCurrency(bill.total)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              if (bill.status == BillStatus.pending)
                TextButton(
                  onPressed: () => _markAsPaid(bill),
                  child: const Text('Mark Paid'),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          Text(
            '${bill.items.length} item(s)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
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
              color: const Color(0xFF2196F3).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_outlined,
              size: 64,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No bills yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Create your first bill for ${widget.shop.name}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToBillForm(),
            icon: const Icon(Icons.add),
            label: const Text("Create Bill"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
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
        title: Text('${widget.shop.name} Bills'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadBills,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2196F3),
              ),
            )
          : bills.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bills.length,
                  itemBuilder: (context, index) =>
                      _buildBillCard(bills[index], index),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToBillForm(),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("New Bill"),
      ),
    );
  }
}
