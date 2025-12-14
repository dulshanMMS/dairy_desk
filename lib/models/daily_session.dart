// Daily Session - Tracks daily business activities
class DailySession {
  final String? id;
  final DateTime date;
  final String businessType; // 'dairy', 'farm', 'shop'
  final List<DailyProductEntry> products;
  final String? notes;
  final bool isClosed;
  final DateTime createdAt;
  final DateTime? closedAt;

  DailySession({
    this.id,
    required this.date,
    required this.businessType,
    this.products = const [],
    this.notes,
    this.isClosed = false,
    DateTime? createdAt,
    this.closedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate total items sent today
  int get totalItemsSent => products.fold(0, (sum, p) => sum + p.sentCount);

  // Calculate total items returned today
  int get totalItemsReturned => products.fold(0, (sum, p) => sum + p.returnCount);

  // Calculate total items sold today
  int get totalItemsSold => products.fold(0, (sum, p) => sum + p.soldCount);

  // Calculate net items (sent - returned)
  int get netItems => totalItemsSent - totalItemsReturned;

  // Calculate total revenue
  double get totalRevenue => products.fold(0.0, (sum, p) => sum + p.totalRevenue);

  // Calculate total cost
  double get totalCost => products.fold(0.0, (sum, p) => sum + p.totalCost);

  // Calculate profit
  double get profit => totalRevenue - totalCost;

  DailySession copyWith({
    String? id,
    DateTime? date,
    String? businessType,
    List<DailyProductEntry>? products,
    String? notes,
    bool? isClosed,
    DateTime? createdAt,
    DateTime? closedAt,
  }) {
    return DailySession(
      id: id ?? this.id,
      date: date ?? this.date,
      businessType: businessType ?? this.businessType,
      products: products ?? this.products,
      notes: notes ?? this.notes,
      isClosed: isClosed ?? this.isClosed,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'date': date.toIso8601String(),
      'businessType': businessType,
      'products': products.map((p) => p.toMap()).toList(),
      if (notes != null) 'notes': notes,
      'isClosed': isClosed,
      'createdAt': createdAt.toIso8601String(),
      if (closedAt != null) 'closedAt': closedAt!.toIso8601String(),
    };
  }

  factory DailySession.fromMap(Map<String, dynamic> map) {
    return DailySession(
      id: map['_id']?.toString(),
      date: DateTime.parse(map['date']),
      businessType: map['businessType'] ?? 'dairy',
      products: (map['products'] as List<dynamic>? ?? [])
          .map((p) => DailyProductEntry.fromMap(p))
          .toList(),
      notes: map['notes'],
      isClosed: map['isClosed'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      closedAt: map['closedAt'] != null
          ? DateTime.parse(map['closedAt'])
          : null,
    );
  }
}

// Daily Product Entry - Daily transaction data for a specific product
class DailyProductEntry {
  final String productId; // Reference to ProductMaster
  final String productName; // Cached for display
  final int sentCount; // Items sent out/available at start
  final int returnCount; // Items returned at day end
  final int soldCount; // Items actually sold
  final double buyPrice; // Price at which bought (cached from ProductMaster)
  final double sellPrice; // Price at which sold (cached from ProductMaster)
  final String? shopId; // If distributed to a specific shop
  final String? notes;

  DailyProductEntry({
    required this.productId,
    required this.productName,
    this.sentCount = 0,
    this.returnCount = 0,
    this.soldCount = 0,
    required this.buyPrice,
    required this.sellPrice,
    this.shopId,
    this.notes,
  });

  // Calculate net items (sent - returned)
  int get netCount => sentCount - returnCount;

  // Calculate actual sold vs recorded sold
  int get calculatedSold => sentCount - returnCount;

  // Calculate total revenue
  double get totalRevenue => soldCount * sellPrice;

  // Calculate total cost
  double get totalCost => soldCount * buyPrice;

  // Calculate profit
  double get profit => totalRevenue - totalCost;

  // Calculate profit margin
  double get profitMargin => totalCost > 0 ? ((profit / totalCost) * 100) : 0;

  DailyProductEntry copyWith({
    String? productId,
    String? productName,
    int? sentCount,
    int? returnCount,
    int? soldCount,
    double? buyPrice,
    double? sellPrice,
    String? shopId,
    String? notes,
  }) {
    return DailyProductEntry(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sentCount: sentCount ?? this.sentCount,
      returnCount: returnCount ?? this.returnCount,
      soldCount: soldCount ?? this.soldCount,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      shopId: shopId ?? this.shopId,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'sentCount': sentCount,
      'returnCount': returnCount,
      'soldCount': soldCount,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      if (shopId != null) 'shopId': shopId,
      if (notes != null) 'notes': notes,
    };
  }

  factory DailyProductEntry.fromMap(Map<String, dynamic> map) {
    return DailyProductEntry(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      sentCount: map['sentCount'] ?? 0,
      returnCount: map['returnCount'] ?? 0,
      soldCount: map['soldCount'] ?? 0,
      buyPrice: (map['buyPrice'] ?? 0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0).toDouble(),
      shopId: map['shopId'],
      notes: map['notes'],
    );
  }
}

