import 'package:mongo_dart/mongo_dart.dart';
import '../models/product.dart';
import '../models/farm_item.dart';
import '../models/shop.dart';
import '../models/bill.dart';

class DBService {
  static Db? _db;
  static late DbCollection dairyCollection;
  static late DbCollection farmCollection;
  static late DbCollection shopCollection;
  static late DbCollection billCollection;

  // Replace with your MongoDB Atlas connection string
  static const _mongoUrl = "mongodb+srv://dairydesk0:BafyS9Ikw8Wd4rcm@cluster0.awdhjs1.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
  static const _dbName = "dairydesk";

  static Future<void> connect() async {
    _db = await Db.create("$_mongoUrl/$_dbName");
    await _db!.open();

    dairyCollection = _db!.collection('dairy_products');
    farmCollection = _db!.collection('farm_products');
    shopCollection = _db!.collection('shops');
    billCollection = _db!.collection('bills');
  }

  static Future<void> close() async {
    await _db?.close();
  }

  // Dairy Product CRUD operations
  static Future<List<Product>> getDairyProducts() async {
    try {
      final data = await dairyCollection.find().toList();
      return data.map((item) => Product.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch dairy products: $e');
    }
  }

  static Future<Product> addDairyProduct(Product product) async {
    try {
      final result = await dairyCollection.insertOne(product.toMap());
      return product.copyWith(id: result.id);
    } catch (e) {
      throw Exception('Failed to add dairy product: $e');
    }
  }

  static Future<void> updateDairyProduct(Product product) async {
    try {
      if (product.id == null) throw Exception('Product ID is required for update');
      await dairyCollection.replaceOne(
        where.id(product.id!),
        product.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update dairy product: $e');
    }
  }

  static Future<void> deleteDairyProduct(ObjectId id) async {
    try {
      await dairyCollection.deleteOne(where.id(id));
    } catch (e) {
      throw Exception('Failed to delete dairy product: $e');
    }
  }

  // Farm Item CRUD operations
  static Future<List<FarmItem>> getFarmItems() async {
    try {
      final data = await farmCollection.find().toList();
      return data.map((item) => FarmItem.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch farm items: $e');
    }
  }

  static Future<FarmItem> addFarmItem(FarmItem farmItem) async {
    try {
      final result = await farmCollection.insertOne(farmItem.toMap());
      return farmItem.copyWith(id: result.id);
    } catch (e) {
      throw Exception('Failed to add farm item: $e');
    }
  }

  static Future<void> updateFarmItem(FarmItem farmItem) async {
    try {
      if (farmItem.id == null) throw Exception('Farm item ID is required for update');
      await farmCollection.replaceOne(
        where.id(farmItem.id!),
        farmItem.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update farm item: $e');
    }
  }

  static Future<void> deleteFarmItem(ObjectId id) async {
    try {
      await farmCollection.deleteOne(where.id(id));
    } catch (e) {
      throw Exception('Failed to delete farm item: $e');
    }
  }

  // Shop CRUD operations
  static Future<List<Shop>> getShops() async {
    try {
      final data = await shopCollection.find().toList();
      return data.map((item) => Shop.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch shops: $e');
    }
  }

  static Future<Shop> addShop(Shop shop) async {
    try {
      final result = await shopCollection.insertOne(shop.toMap());
      return shop.copyWith(id: result.id);
    } catch (e) {
      throw Exception('Failed to add shop: $e');
    }
  }

  static Future<void> updateShop(Shop shop) async {
    try {
      if (shop.id == null) throw Exception('Shop ID is required for update');
      await shopCollection.replaceOne(
        where.id(shop.id!),
        shop.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update shop: $e');
    }
  }

  static Future<void> deleteShop(ObjectId id) async {
    try {
      await shopCollection.deleteOne(where.id(id));
    } catch (e) {
      throw Exception('Failed to delete shop: $e');
    }
  }

  // Bill CRUD operations
  static Future<List<Bill>> getBills() async {
    try {
      final data = await billCollection.find().toList();
      return data.map((item) => Bill.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch bills: $e');
    }
  }

  static Future<List<Bill>> getBillsByShop(ObjectId shopId) async {
    try {
      final data = await billCollection.find(where.eq('shopId', shopId)).toList();
      return data.map((item) => Bill.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch bills for shop: $e');
    }
  }

  static Future<List<Bill>> getUnpaidBills() async {
    try {
      final data = await billCollection.find(where.ne('status', 'paid')).toList();
      return data.map((item) => Bill.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch unpaid bills: $e');
    }
  }

  static Future<Bill> addBill(Bill bill) async {
    try {
      final result = await billCollection.insertOne(bill.toMap());
      return bill.copyWith(id: result.id);
    } catch (e) {
      throw Exception('Failed to add bill: $e');
    }
  }

  static Future<void> updateBill(Bill bill) async {
    try {
      if (bill.id == null) throw Exception('Bill ID is required for update');
      await billCollection.replaceOne(
        where.id(bill.id!),
        bill.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update bill: $e');
    }
  }

  static Future<void> markBillAsPaid(ObjectId billId, PaymentMethod paymentMethod) async {
    try {
      await billCollection.updateOne(
        where.id(billId),
        modify
            .set('status', 'paid')
            .set('paymentMethod', paymentMethod.toString().split('.').last)
            .set('paidDate', DateTime.now().toIso8601String()),
      );
    } catch (e) {
      throw Exception('Failed to mark bill as paid: $e');
    }
  }

  static Future<void> deleteBill(ObjectId id) async {
    try {
      await billCollection.deleteOne(where.id(id));
    } catch (e) {
      throw Exception('Failed to delete bill: $e');
    }
  }

  // Search operations
  static Future<List<Shop>> searchShops(String query) async {
    try {
      final data = await shopCollection.find(where.regex('name', query, caseInsensitive: true)).toList();
      return data.map((item) => Shop.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to search shops: $e');
    }
  }

  static Future<List<Product>> searchDairyProducts(String query) async {
    try {
      final data = await dairyCollection.find(where.regex('name', query, caseInsensitive: true)).toList();
      return data.map((item) => Product.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to search dairy products: $e');
    }
  }
}
