import 'package:mongo_dart/mongo_dart.dart';
import '../models/product.dart';
import '../models/farm_item.dart';
import '../models/shop.dart';
import '../models/bill.dart';
import '../models/product_master.dart';
import '../models/daily_session.dart';

class DBService {
  static Db? _db;
  static DbCollection? dairyCollection;
  static DbCollection? farmCollection;
  static DbCollection? shopCollection;
  static DbCollection? billCollection;
  static DbCollection? userCollection; // Added for authentication
  static DbCollection? productMasterCollection;
  static DbCollection? dailySessionCollection;

  // Add public getter for database instance
  static Db? get database => _db;

  // Updated MongoDB connection string
  static const _mongoUrl = "mongodb+srv://dairydesk11_db_user:S2lzwE84G2dilAkc@cluster0.vnzjdm4.mongodb.net/?appName=Cluster0";
  static const _dbName = "dairydesk";

  // REVERTED: Back to original simple connection method
  static Future<void> connect() async {
    try {
      _db = await Db.create("$_mongoUrl/$_dbName");
      await _db!.open();

      dairyCollection = _db!.collection('dairy_products');
      farmCollection = _db!.collection('farm_products');
      shopCollection = _db!.collection('shops');
      billCollection = _db!.collection('bills');
      userCollection = _db!.collection('users'); // Added for authentication
      productMasterCollection = _db!.collection('product_master');
      dailySessionCollection = _db!.collection('daily_sessions');

      // Initialize authentication service
      await _initializeAuth();
    } catch (e) {
      print('! Database connection failed, running in offline mode: $e');
      // Collections remain null, operations will handle gracefully
      rethrow;
    }
  }

  // Initialize authentication and create default user if needed
  static Future<void> _initializeAuth() async {
    try {
      if (userCollection == null) return;

      // Check if any users exist
      final userCount = await userCollection!.count();
      if (userCount == 0) {
        // Create default admin user
        await userCollection!.insertOne({
          'email': 'admin@dairydesk.com',
          'name': 'Admin User',
          'phone': '',
          'role': 'admin',
          'isActive': true,
          'createdDate': DateTime.now().toIso8601String(),
          'lastLogin': DateTime.now().toIso8601String(),
          'passwordHash': 'ef2d127de37b942baad06145e54b0c619a1f22327b2ebbcfbec78f5564afe39d', // admin123
          'isDefaultUser': true,
        });
        print('✅ Default admin user created: admin@dairydesk.com / admin123');
      }
    } catch (e) {
      print('⚠️ Failed to initialize auth: $e');
    }
  }

  static Future<void> close() async {
    await _db?.close();
  }

  // KEPT: All the new CRUD methods below...

  // Dairy Products Operations
  static Future<List<Product>> getDairyProducts() async {
    try {
      if (dairyCollection == null) {
        throw Exception('Database not connected');
      }
      final data = await dairyCollection!.find().toList();
      return data.map((map) => Product.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch dairy products: $e');
    }
  }

  static Future<Product> addDairyProduct(Product product) async {
    try {
      if (dairyCollection == null) {
        throw Exception('Database not connected');
      }
      final result = await dairyCollection!.insertOne(product.toMap());
      return product.copyWith(id: result.id.toString());
    } catch (e) {
      throw Exception('Failed to add dairy product: $e');
    }
  }

  static Future<void> updateDairyProduct(String id, Product product) async {
    try {
      if (dairyCollection == null) {
        throw Exception('Database not connected');
      }
      final productMap = product.toMap();
      await dairyCollection!.updateOne(
        where.id(ObjectId.parse(id)),
        modify
            .set('name', productMap['name'])
            .set('buyPrice', productMap['buyPrice'])
            .set('sellPrice', productMap['sellPrice'])
            .set('stock', productMap['stock'])
            .set('returns', productMap['returns'])
            .set('date', productMap['date'])
            .set('category', productMap['category']),
      );
    } catch (e) {
      throw Exception('Failed to update dairy product: $e');
    }
  }

  static Future<void> deleteDairyProduct(String id) async {
    try {
      if (dairyCollection == null) {
        throw Exception('Database not connected');
      }
      await dairyCollection!.deleteOne(where.id(ObjectId.parse(id)));
    } catch (e) {
      throw Exception('Failed to delete dairy product: $e');
    }
  }

  // Farm Items Operations
  static Future<List<FarmItem>> getFarmItems() async {
    try {
      if (farmCollection == null) {
        throw Exception('Database not connected');
      }
      final data = await farmCollection!.find().toList();
      return data.map((map) => FarmItem.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch farm items: $e');
    }
  }

  static Future<FarmItem> addFarmItem(FarmItem item) async {
    try {
      if (farmCollection == null) {
        throw Exception('Database not connected');
      }
      final result = await farmCollection!.insertOne(item.toMap());
      return item.copyWith(id: result.id.toString());
    } catch (e) {
      throw Exception('Failed to add farm item: $e');
    }
  }

  static Future<void> updateFarmItem(String id, FarmItem item) async {
    try {
      if (farmCollection == null) {
        throw Exception('Database not connected');
      }
      final itemMap = item.toMap();
      await farmCollection!.updateOne(
        where.id(ObjectId.parse(id)),
        modify
            .set('name', itemMap['name'])
            .set('type', itemMap['type'])
            .set('details', itemMap['details'])
            .set('createdDate', itemMap['createdDate'])
            .set('lastUpdated', itemMap['lastUpdated']),
      );
    } catch (e) {
      throw Exception('Failed to update farm item: $e');
    }
  }

  static Future<void> deleteFarmItem(String id) async {
    try {
      if (farmCollection == null) {
        throw Exception('Database not connected');
      }
      await farmCollection!.deleteOne(where.id(ObjectId.parse(id)));
    } catch (e) {
      throw Exception('Failed to delete farm item: $e');
    }
  }

  // Shop Operations
  static Future<List<Shop>> getShops() async {
    try {
      if (shopCollection == null) {
        throw Exception('Database not connected');
      }
      final data = await shopCollection!.find().toList();
      return data.map((map) => Shop.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch shops: $e');
    }
  }

  static Future<Shop> addShop(Shop shop) async {
    try {
      if (shopCollection == null) {
        throw Exception('Database not connected');
      }
      final result = await shopCollection!.insertOne(shop.toMap());
      return shop.copyWith(id: result.id.toString());
    } catch (e) {
      throw Exception('Failed to add shop: $e');
    }
  }

  static Future<void> updateShop(String id, Shop shop) async {
    try {
      if (shopCollection == null) {
        throw Exception('Database not connected');
      }
      final shopMap = shop.toMap();
      await shopCollection!.updateOne(
        where.id(ObjectId.parse(id)),
        modify
            .set('name', shopMap['name'])
            .set('address', shopMap['address'])
            .set('phone', shopMap['phone'])
            .set('email', shopMap['email'])
            .set('ownerName', shopMap['ownerName'])
            .set('isActive', shopMap['isActive'])
            .set('settings', shopMap['settings']),
      );
    } catch (e) {
      throw Exception('Failed to update shop: $e');
    }
  }

  static Future<void> deleteShop(String id) async {
    try {
      if (shopCollection == null) {
        throw Exception('Database not connected');
      }
      await shopCollection!.deleteOne(where.id(ObjectId.parse(id)));
    } catch (e) {
      throw Exception('Failed to delete shop: $e');
    }
  }

  // Bill Operations
  static Future<List<Bill>> getBills({String? shopId}) async {
    try {
      if (billCollection == null) {
        throw Exception('Database not connected');
      }
      final query = shopId != null ? where.eq('shopId', shopId) : where;
      final data = await billCollection!.find(query).toList();
      return data.map((map) => Bill.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch bills: $e');
    }
  }

  static Future<Bill> addBill(Bill bill) async {
    try {
      if (billCollection == null) {
        throw Exception('Database not connected');
      }
      final result = await billCollection!.insertOne(bill.toMap());
      return bill.copyWith(id: result.id.toString());
    } catch (e) {
      throw Exception('Failed to add bill: $e');
    }
  }

  static Future<void> updateBill(String id, Bill bill) async {
    try {
      if (billCollection == null) {
        throw Exception('Database not connected');
      }
      final billMap = bill.toMap();
      await billCollection!.updateOne(
        where.id(ObjectId.parse(id)),
        modify
            .set('billNumber', billMap['billNumber'])
            .set('shopId', billMap['shopId'])
            .set('customerName', billMap['customerName'])
            .set('customerPhone', billMap['customerPhone'])
            .set('customerAddress', billMap['customerAddress'])
            .set('items', billMap['items'])
            .set('subtotal', billMap['subtotal'])
            .set('tax', billMap['tax'])
            .set('discount', billMap['discount'])
            .set('totalAmount', billMap['totalAmount'])
            .set('status', billMap['status'])
            .set('paymentMethod', billMap['paymentMethod'])
            .set('dueDate', billMap['dueDate'])
            .set('paidDate', billMap['paidDate'])
            .set('metadata', billMap['metadata']),
      );
    } catch (e) {
      throw Exception('Failed to update bill: $e');
    }
  }

  static Future<void> deleteBill(String id) async {
    try {
      if (billCollection == null) {
        throw Exception('Database not connected');
      }
      await billCollection!.deleteOne(where.id(ObjectId.parse(id)));
    } catch (e) {
      throw Exception('Failed to delete bill: $e');
    }
  }

  // Search methods (fallback to Dart filtering)
  static Future<List<Product>> searchDairyProducts(String searchTerm) async {
    try {
      final allProducts = await getDairyProducts();
      return allProducts.where((product) =>
          product.name.toLowerCase().contains(searchTerm.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Failed to search dairy products: $e');
    }
  }

  static Future<List<Shop>> searchShops(String searchTerm) async {
    try {
      final allShops = await getShops();
      return allShops.where((shop) =>
      shop.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          shop.ownerName.toLowerCase().contains(searchTerm.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Failed to search shops: $e');
    }
  }

  static Future<List<Bill>> searchBills(String searchTerm, {String? shopId}) async {
    try {
      final bills = await getBills(shopId: shopId);
      return bills.where((bill) =>
      bill.customerName.toLowerCase().contains(searchTerm.toLowerCase()) ||
          bill.billNumber.toLowerCase().contains(searchTerm.toLowerCase()) ||
          bill.customerPhone.contains(searchTerm)
      ).toList();
    } catch (e) {
      throw Exception('Failed to search bills: $e');
    }
  }

  // Utility methods
  static Future<bool> isDatabaseConnected() async {
    try {
      return _db?.isConnected ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> reconnect() async {
    try {
      await close();
      await connect();
    } catch (e) {
      throw Exception('Failed to reconnect to database: $e');
    }
  }

  // ============ Product Master Operations ============

  static Future<List<ProductMaster>> getProductMasters({String? category}) async {
    try {
      if (productMasterCollection == null) {
        throw Exception('Database not connected');
      }
      final query = category != null ? where.eq('category', category).eq('isActive', true) : where.eq('isActive', true);
      final data = await productMasterCollection!.find(query).toList();
      return data.map((map) => ProductMaster.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch product masters: $e');
    }
  }

  static Future<ProductMaster?> getProductMasterById(String id) async {
    try {
      if (productMasterCollection == null) {
        throw Exception('Database not connected');
      }
      final data = await productMasterCollection!.findOne(where.id(ObjectId.parse(id)));
      return data != null ? ProductMaster.fromMap(data) : null;
    } catch (e) {
      throw Exception('Failed to fetch product master: $e');
    }
  }

  static Future<ProductMaster> addProductMaster(ProductMaster product) async {
    try {
      if (productMasterCollection == null) {
        throw Exception('Database not connected');
      }
      final result = await productMasterCollection!.insertOne(product.toMap());
      return product.copyWith(id: result.id.toString());
    } catch (e) {
      throw Exception('Failed to add product master: $e');
    }
  }

  static Future<bool> updateProductMaster(ProductMaster product) async {
    try {
      if (productMasterCollection == null || product.id == null) {
        throw Exception('Database not connected or product ID is null');
      }
      final productMap = product.toMap();
      final result = await productMasterCollection!.updateOne(
        where.id(ObjectId.parse(product.id!)),
        modify
            .set('name', productMap['name'])
            .set('category', productMap['category'])
            .set('buyPrice', productMap['buyPrice'])
            .set('sellPrice', productMap['sellPrice'])
            .set('unit', productMap['unit'])
            .set('isActive', productMap['isActive'])
            .set('updatedAt', DateTime.now().toIso8601String()),
      );
      return result.isSuccess;
    } catch (e) {
      throw Exception('Failed to update product master: $e');
    }
  }

  static Future<bool> deleteProductMaster(String id) async {
    try {
      if (productMasterCollection == null) {
        throw Exception('Database not connected');
      }
      // Soft delete by setting isActive to false
      final result = await productMasterCollection!.updateOne(
        where.id(ObjectId.parse(id)),
        modify.set('isActive', false).set('updatedAt', DateTime.now().toIso8601String()),
      );
      return result.isSuccess;
    } catch (e) {
      throw Exception('Failed to delete product master: $e');
    }
  }

  static Future<List<ProductMaster>> searchProductMasters(String searchTerm) async {
    try {
      final allProducts = await getProductMasters();
      return allProducts.where((product) =>
          product.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          product.category.toLowerCase().contains(searchTerm.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Failed to search product masters: $e');
    }
  }

  // ============ Daily Session Operations ============

  static Future<List<DailySession>> getDailySessions({
    String? businessType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (dailySessionCollection == null) {
        throw Exception('Database not connected');
      }

      var query = where;
      if (businessType != null) {
        query = query.eq('businessType', businessType);
      }
      if (startDate != null && endDate != null) {
        query = query.gte('date', startDate.toIso8601String()).lte('date', endDate.toIso8601String());
      }

      final data = await dailySessionCollection!.find(query.sortBy('date', descending: true)).toList();
      return data.map((map) => DailySession.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch daily sessions: $e');
    }
  }

  static Future<DailySession?> getDailySessionById(String id) async {
    try {
      if (dailySessionCollection == null) {
        throw Exception('Database not connected');
      }
      final data = await dailySessionCollection!.findOne(where.id(ObjectId.parse(id)));
      return data != null ? DailySession.fromMap(data) : null;
    } catch (e) {
      throw Exception('Failed to fetch daily session: $e');
    }
  }

  static Future<DailySession> createDailySession(DailySession session) async {
    try {
      if (dailySessionCollection == null) {
        throw Exception('Database not connected');
      }
      final result = await dailySessionCollection!.insertOne(session.toMap());
      return session.copyWith(id: result.id.toString());
    } catch (e) {
      throw Exception('Failed to create daily session: $e');
    }
  }

  static Future<bool> updateDailySession(DailySession session) async {
    try {
      if (dailySessionCollection == null || session.id == null) {
        throw Exception('Database not connected or session ID is null');
      }
      final sessionMap = session.toMap();
      final result = await dailySessionCollection!.updateOne(
        where.id(ObjectId.parse(session.id!)),
        modify
            .set('date', sessionMap['date'])
            .set('businessType', sessionMap['businessType'])
            .set('products', sessionMap['products'])
            .set('notes', sessionMap['notes'])
            .set('isClosed', sessionMap['isClosed'])
            .set('closedAt', sessionMap['closedAt']),
      );
      return result.isSuccess;
    } catch (e) {
      throw Exception('Failed to update daily session: $e');
    }
  }

  static Future<bool> deleteDailySession(String id) async {
    try {
      if (dailySessionCollection == null) {
        throw Exception('Database not connected');
      }
      final result = await dailySessionCollection!.deleteOne(where.id(ObjectId.parse(id)));
      return result.isSuccess;
    } catch (e) {
      throw Exception('Failed to delete daily session: $e');
    }
  }
}