import '../models/shop.dart';
import 'db_service.dart';

class ProfitReport {
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double profitMargin;
  final int totalSales;
  final DateTime startDate;
  final DateTime endDate;
  final List<ProductProfitData> productProfits;
  final List<ShopProfitData> shopProfits;

  ProfitReport({
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.profitMargin,
    required this.totalSales,
    required this.startDate,
    required this.endDate,
    required this.productProfits,
    required this.shopProfits,
  });
}

class ProductProfitData {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;
  final double cost;
  final double profit;
  final double profitMargin;

  ProductProfitData({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.profitMargin,
  });
}

class ShopProfitData {
  final String shopId;
  final String shopName;
  final double revenue;
  final double cost;
  final double profit;
  final double profitMargin;
  final int billCount;

  ShopProfitData({
    required this.shopId,
    required this.shopName,
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.profitMargin,
    required this.billCount,
  });
}

class ProfitAnalyticsService {
  // Generate comprehensive profit report for a date range
  static Future<ProfitReport> generateProfitReport({
    required DateTime startDate,
    required DateTime endDate,
    String? shopId,
  }) async {
    try {
      // Get all bills in the date range
      final bills = await DBService.getBills(shopId: shopId);
      final filteredBills = bills.where((bill) =>
          bill.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          bill.date.isBefore(endDate.add(const Duration(days: 1)))).toList();

      // Calculate overall totals
      double totalRevenue = 0;
      double totalCost = 0;
      double totalProfit = 0;
      int totalSales = filteredBills.length;

      // Track product-wise profits
      Map<String, ProductProfitData> productProfits = {};

      // Track shop-wise profits
      Map<String, ShopProfitData> shopProfits = {};

      for (final bill in filteredBills) {
        totalRevenue += bill.totalAmount;
        totalCost += bill.totalCost;
        totalProfit += bill.totalProfit;

        // Process each bill item for product analysis
        for (final item in bill.items) {
          final key = item.productId;
          if (productProfits.containsKey(key)) {
            final existing = productProfits[key]!;
            productProfits[key] = ProductProfitData(
              productId: existing.productId,
              productName: existing.productName,
              quantitySold: existing.quantitySold + item.quantity,
              revenue: existing.revenue + item.totalAmount,
              cost: existing.cost + (item.buyPrice * item.quantity),
              profit: existing.profit + item.profit,
              profitMargin: existing.cost + (item.buyPrice * item.quantity) > 0
                  ? ((existing.profit + item.profit) / (existing.cost + (item.buyPrice * item.quantity))) * 100
                  : 0,
            );
          } else {
            productProfits[key] = ProductProfitData(
              productId: item.productId,
              productName: item.productName,
              quantitySold: item.quantity,
              revenue: item.totalAmount,
              cost: item.buyPrice * item.quantity,
              profit: item.profit,
              profitMargin: item.profitMargin,
            );
          }
        }

        // Process shop-wise profits
        final shopKey = bill.shopId;
        if (shopProfits.containsKey(shopKey)) {
          final existing = shopProfits[shopKey]!;
          shopProfits[shopKey] = ShopProfitData(
            shopId: existing.shopId,
            shopName: existing.shopName,
            revenue: existing.revenue + bill.totalAmount,
            cost: existing.cost + bill.totalCost,
            profit: existing.profit + bill.totalProfit,
            profitMargin: existing.cost + bill.totalCost > 0
                ? ((existing.profit + bill.totalProfit) / (existing.cost + bill.totalCost)) * 100
                : 0,
            billCount: existing.billCount + 1,
          );
        } else {
          // Get shop name (you'll need to fetch from shops collection)
          final shops = await DBService.getShops();
          final shop = shops.firstWhere((s) => s.id == bill.shopId,
              orElse: () => Shop(
                id: bill.shopId,
                name: 'Unknown Shop',
                address: '',
                ownerName: '',
                createdDate: DateTime.now(),
              ));

          shopProfits[shopKey] = ShopProfitData(
            shopId: bill.shopId,
            shopName: shop.name,
            revenue: bill.totalAmount,
            cost: bill.totalCost,
            profit: bill.totalProfit,
            profitMargin: bill.profitMargin,
            billCount: 1,
          );
        }
      }

      final profitMargin = totalCost > 0 ? (totalProfit / totalCost) * 100 : 0;

      return ProfitReport(
        totalRevenue: totalRevenue,
        totalCost: totalCost,
        totalProfit: totalProfit,
        profitMargin: profitMargin.toDouble(),
        totalSales: totalSales,
        startDate: startDate,
        endDate: endDate,
        productProfits: productProfits.values.toList(),
        shopProfits: shopProfits.values.toList(),
      );
    } catch (e) {
      throw Exception('Failed to generate profit report: $e');
    }
  }

  // Get today's profit summary
  static Future<ProfitReport> getTodaysProfits() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return generateProfitReport(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  // Get this month's profit summary
  static Future<ProfitReport> getMonthlyProfits() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    return generateProfitReport(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  // Get yearly profit summary
  static Future<ProfitReport> getYearlyProfits() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);

    return generateProfitReport(
      startDate: startOfYear,
      endDate: endOfYear,
    );
  }

  // Get top performing products
  static Future<List<ProductProfitData>> getTopPerformingProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    final report = await generateProfitReport(
      startDate: start,
      endDate: end,
    );

    final sortedProducts = List<ProductProfitData>.from(report.productProfits);
    sortedProducts.sort((a, b) => b.profit.compareTo(a.profit));

    return sortedProducts.take(limit).toList();
  }

  // Calculate potential profit from current stock
  static Future<double> calculatePotentialProfitFromStock() async {
    try {
      final products = await DBService.getDairyProducts();
      return products.fold<double>(0, (sum, product) => sum + product.potentialProfit);
    } catch (e) {
      throw Exception('Failed to calculate potential profit: $e');
    }
  }

  // Get profit trend data for charts (daily profits for last 30 days)
  static Future<List<DailyProfitData>> getProfitTrendData() async {
    final List<DailyProfitData> trendData = [];
    final now = DateTime.now();

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final dayReport = await generateProfitReport(
        startDate: startOfDay,
        endDate: endOfDay,
      );

      trendData.add(DailyProfitData(
        date: startOfDay,
        profit: dayReport.totalProfit,
        revenue: dayReport.totalRevenue,
        sales: dayReport.totalSales,
      ));
    }

    return trendData;
  }
}

class DailyProfitData {
  final DateTime date;
  final double profit;
  final double revenue;
  final int sales;

  DailyProfitData({
    required this.date,
    required this.profit,
    required this.revenue,
    required this.sales,
  });
}
