class Sale {
  final String? id;
  final String itemId;
  final int quantity;
  final double price;
  final DateTime date;

  Sale({
    this.id,
    required this.itemId,
    required this.quantity,
    required this.price,
    required this.date,
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['_id']?.toString(),
      itemId: map['itemId'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'quantity': quantity,
      'price': price,
      'date': date.toIso8601String(),
    };
  }
}
