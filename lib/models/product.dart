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
    this.returns = 0,
    required this.date,
    required this.category,
  });

  // Calculate profit per unit
  double get profitPerUnit => sellPrice - buyPrice;

  // Calculate total profit if all stock is sold
  double get potentialProfit => profitPerUnit * stock;

  // Calculate total profit (alias for UI compatibility)
  double get profit => potentialProfit;

  // Calculate profit margin percentage
  double get profitMargin => buyPrice > 0 ? (profitPerUnit / buyPrice) * 100 : 0;

  // Calculate available stock (stock minus returns)
  int get availableStock => stock - returns;

  // Calculate total investment
  double get totalInvestment => buyPrice * stock;

  // Calculate total revenue if all sold
  double get totalRevenue => sellPrice * stock;

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

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'stock': stock,
      'returns': returns,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['_id']?.toString(),
      name: map['name'] ?? '',
      buyPrice: (map['buyPrice'] ?? 0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      returns: map['returns'] ?? 0,
      date: DateTime.parse(map['date']),
      category: map['category'] ?? '',
    );
  }
}