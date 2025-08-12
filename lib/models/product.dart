import 'package:mongo_dart/mongo_dart.dart';

class Product {
  final ObjectId? id;
  final String name;
  final double buyPrice;
  final double sellPrice;
  final int stock;
  final int returns;
  final DateTime date;

  Product({
    this.id,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    required this.returns,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['_id'] as ObjectId?,
      name: map['name'] as String,
      buyPrice: (map['buyPrice'] as num).toDouble(),
      sellPrice: (map['sellPrice'] as num).toDouble(),
      stock: map['stock'] as int,
      returns: map['returns'] as int,
      date: map['date'] is String 
          ? DateTime.parse(map['date']) 
          : map['date'] as DateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'stock': stock,
      'returns': returns,
      'date': date.toIso8601String(),
    };
  }

  Product copyWith({
    ObjectId? id,
    String? name,
    double? buyPrice,
    double? sellPrice,
    int? stock,
    int? returns,
    DateTime? date,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stock: stock ?? this.stock,
      returns: returns ?? this.returns,
      date: date ?? this.date,
    );
  }

  double get profit {
    return (sellPrice - buyPrice) * (stock - returns);
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, buyPrice: $buyPrice, sellPrice: $sellPrice, stock: $stock, returns: $returns, date: $date}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.buyPrice == buyPrice &&
        other.sellPrice == sellPrice &&
        other.stock == stock &&
        other.returns == returns &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        buyPrice.hashCode ^
        sellPrice.hashCode ^
        stock.hashCode ^
        returns.hashCode ^
        date.hashCode;
  }
}
