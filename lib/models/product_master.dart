// Product Master - Static product information
class ProductMaster {
  final String? id;
  final String name;
  final String category;
  final double buyPrice;
  final double sellPrice;
  final String unit; // liter, kg, piece, etc.
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductMaster({
    this.id,
    required this.name,
    required this.category,
    required this.buyPrice,
    required this.sellPrice,
    this.unit = 'piece',
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate profit per unit
  double get profitPerUnit => sellPrice - buyPrice;

  // Calculate profit margin percentage
  double get profitMargin => buyPrice > 0 ? (profitPerUnit / buyPrice) * 100 : 0;

  ProductMaster copyWith({
    String? id,
    String? name,
    String? category,
    double? buyPrice,
    double? sellPrice,
    String? unit,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductMaster(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'category': category,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'unit': unit,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  factory ProductMaster.fromMap(Map<String, dynamic> map) {
    return ProductMaster(
      id: map['_id']?.toString(),
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      buyPrice: (map['buyPrice'] ?? 0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'piece',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }
}

