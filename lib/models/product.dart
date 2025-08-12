class Product {
  final String? id;
  final String name;
  final double buyPrice;
  final double sellPrice;
  final int stock;
  final int returns;
  final DateTime date;
  final String category;

  Product({
    this.id,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    required this.returns,
    required this.date,
    this.category = 'dairy',
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['_id']?.toString(),
      name: map['name'] ?? '',
      buyPrice: (map['buyPrice'] ?? 0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      returns: map['returns'] ?? 0,
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      category: map['category'] ?? 'dairy',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'stock': stock,
      'returns': returns,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  double get profit => (sellPrice - buyPrice) * (stock - returns);
  int get availableStock => stock - returns;
  double get totalInvestment => buyPrice * stock;
  double get totalRevenue => sellPrice * availableStock;

  Product copyWith({
    String? id,
    String? name,
    double? buyPrice,
    double? sellPrice,
    int? stock,
    int? returns,
    DateTime? date,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stock: stock ?? this.stock,
      returns: returns ?? this.returns,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, buyPrice: $buyPrice, sellPrice: $sellPrice, stock: $stock, returns: $returns)';
  }
}