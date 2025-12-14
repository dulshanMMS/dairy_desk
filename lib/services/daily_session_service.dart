import '../models/daily_session.dart';
import '../models/product_master.dart';
import 'db_service.dart';

class DailySessionService {
  // Remove the instance creation, use static methods directly

  // Get or create today's session for a business type
  static Future<DailySession?> getTodaySession(String businessType) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final sessions = await DBService.getDailySessions(
      businessType: businessType,
      startDate: startOfDay,
      endDate: endOfDay,
    );

    if (sessions.isNotEmpty) {
      return sessions.first;
    }
    return null;
  }

  // Create a new daily session
  static Future<DailySession?> createSession(DailySession session) async {
    return await DBService.createDailySession(session);
  }

  // Update an existing session
  static Future<bool> updateSession(DailySession session) async {
    if (session.id == null) return false;
    return await DBService.updateDailySession(session);
  }

  // Close a session (mark as complete)
  static Future<bool> closeSession(String sessionId) async {
    final session = await DBService.getDailySessionById(sessionId);
    if (session == null) return false;

    final closedSession = session.copyWith(
      isClosed: true,
      closedAt: DateTime.now(),
    );

    return await DBService.updateDailySession(closedSession);
  }

  // Add a product entry to today's session
  static Future<bool> addProductEntry(
    String businessType,
    DailyProductEntry entry,
  ) async {
    var session = await getTodaySession(businessType);

    if (session == null) {
      // Create new session
      session = DailySession(
        date: DateTime.now(),
        businessType: businessType,
        products: [entry],
      );
      final created = await createSession(session);
      return created != null;
    } else {
      // Update existing session
      final updatedProducts = List<DailyProductEntry>.from(session.products);

      // Check if product already exists in today's session
      final existingIndex = updatedProducts.indexWhere(
        (p) => p.productId == entry.productId && p.shopId == entry.shopId,
      );

      if (existingIndex >= 0) {
        updatedProducts[existingIndex] = entry;
      } else {
        updatedProducts.add(entry);
      }

      final updatedSession = session.copyWith(products: updatedProducts);
      return await updateSession(updatedSession);
    }
  }

  // Get sessions for a date range
  static Future<List<DailySession>> getSessionsForDateRange(
    String businessType,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await DBService.getDailySessions(
      businessType: businessType,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Get sessions for current month
  static Future<List<DailySession>> getThisMonthSessions(String businessType) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return await getSessionsForDateRange(businessType, startOfMonth, endOfMonth);
  }

  // Calculate total profit for a date range
  static Future<double> getTotalProfit(
    String businessType,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final sessions = await getSessionsForDateRange(businessType, startDate, endDate);
    return sessions.fold<double>(0.0, (sum, session) => sum + session.profit);
  }

  // Get best selling products in a date range
  static Future<Map<String, int>> getBestSellingProducts(
    String businessType,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final sessions = await getSessionsForDateRange(businessType, startDate, endDate);
    final Map<String, int> productSales = {};

    for (var session in sessions) {
      for (var product in session.products) {
        productSales[product.productName] =
            (productSales[product.productName] ?? 0) + product.soldCount;
      }
    }

    return productSales;
  }

  // Get average daily revenue for a date range
  static Future<double> getAverageDailyRevenue(
    String businessType,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final sessions = await getSessionsForDateRange(businessType, startDate, endDate);
    if (sessions.isEmpty) return 0.0;

    final totalRevenue = sessions.fold<double>(0.0, (sum, session) => sum + session.totalRevenue);
    return totalRevenue / sessions.length;
  }

  // Delete a product entry from today's session
  static Future<bool> removeProductEntry(
    String businessType,
    String productId,
    String? shopId,
  ) async {
    final session = await getTodaySession(businessType);
    if (session == null) return false;

    final updatedProducts = session.products.where((p) =>
      !(p.productId == productId && p.shopId == shopId)
    ).toList();

    final updatedSession = session.copyWith(products: updatedProducts);
    return await updateSession(updatedSession);
  }
}
