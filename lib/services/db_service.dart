import 'package:mongo_dart/mongo_dart.dart';

class DBService {
  static Db? _db;
  static late DbCollection dairyCollection;
  static late DbCollection farmCollection;
  static late DbCollection shopCollection;

  // Replace with your MongoDB Atlas connection string
  static const _mongoUrl = "mongodb+srv://dairydesk0:BafyS9Ikw8Wd4rcm@cluster0.awdhjs1.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
  static const _dbName = "dairydesk";

  static Future<void> connect() async {
    _db = await Db.create("$_mongoUrl/$_dbName");
    await _db!.open();

    dairyCollection = _db!.collection('dairy_products');
    farmCollection = _db!.collection('farm_products');
    shopCollection = _db!.collection('shops');
  }

  static Future<void> close() async {
    await _db?.close();
  }
}
