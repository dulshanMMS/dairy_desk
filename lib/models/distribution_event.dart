class DistributionEvent {
  final String? id;
  final DateTime date;
  final String shopId;
  final List<DistributedProduct> products;

  DistributionEvent({
    this.id,
    required this.date,
    required this.shopId,
    required this.products,
  });

  factory DistributionEvent.fromMap(Map<String, dynamic> map) {
    return DistributionEvent(
      id: map['_id']?.toString(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      shopId: map['shopId'] ?? '',
      products: (map['products'] as List<dynamic>? ?? [])
          .map((p) => DistributedProduct.fromMap(p))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'shopId': shopId,
      'products': products.map((p) => p.toMap()).toList(),
    };
  }
}

class DistributedProduct {
  final String productId;
  final int sent;
  final int returned;

  DistributedProduct({
    required this.productId,
    required this.sent,
    required this.returned,
  });

  factory DistributedProduct.fromMap(Map<String, dynamic> map) {
    return DistributedProduct(
      productId: map['productId'] ?? '',
      sent: map['sent'] ?? 0,
      returned: map['returned'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'productId': productId, 'sent': sent, 'returned': returned};
  }
}
