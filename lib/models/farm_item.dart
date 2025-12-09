enum FarmItemType { crop, livestock }

enum CropStatus { planted, growing, ready, harvested }

enum LivestockHealthStatus { excellent, good, fair, poor }

class FarmItem {
  final String? id;
  final String name;
  final String type;
  final Map<String, dynamic> details;
  final DateTime createdDate;
  final DateTime lastUpdated;

  FarmItem({
    this.id,
    required this.name,
    required this.type,
    required this.details,
    required this.createdDate,
    required this.lastUpdated,
  });

  // Convert string type to enum
  FarmItemType get typeEnum => type == 'crop' ? FarmItemType.crop : FarmItemType.livestock;

  // Crop-specific getters
  String? get area => details['area'] as String?;
  CropStatus? get cropStatus => details['cropStatus'] != null
      ? CropStatus.values.firstWhere((e) => e.toString().split('.').last == details['cropStatus'])
      : null;
  DateTime? get plantedDate => details['plantedDate'] != null
      ? DateTime.parse(details['plantedDate'])
      : null;
  DateTime? get expectedHarvestDate => details['expectedHarvestDate'] != null
      ? DateTime.parse(details['expectedHarvestDate'])
      : null;
  double get investment => (details['investment'] ?? 0).toDouble();
  double get expectedRevenue => (details['expectedRevenue'] ?? 0).toDouble();

  // Livestock-specific getters
  int get count => details['count'] ?? 0;
  String? get breed => details['breed'] as String?;
  String? get age => details['age'] as String?;
  LivestockHealthStatus? get healthStatus => details['healthStatus'] != null
      ? LivestockHealthStatus.values.firstWhere((e) => e.toString().split('.').last == details['healthStatus'])
      : null;
  String? get monthlyYield => details['monthlyYield'] as String?;
  double get feedCost => (details['feedCost'] ?? 0).toDouble();
  double get revenue => (details['revenue'] ?? 0).toDouble();

  // Common profit calculations
  double get profit => type == 'crop'
      ? expectedRevenue - investment
      : revenue - feedCost;

  FarmItem copyWith({
    String? id,
    String? name,
    String? type,
    Map<String, dynamic>? details,
    DateTime? createdDate,
    DateTime? lastUpdated,
  }) {
    return FarmItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      details: details ?? this.details,
      createdDate: createdDate ?? this.createdDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'type': type,
      'details': details,
      'createdDate': createdDate.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory FarmItem.fromMap(Map<String, dynamic> map) {
    return FarmItem(
      id: map['_id']?.toString(),
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      createdDate: DateTime.parse(map['createdDate']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}

// Factory methods for creating specific farm items
class FarmItemFactory {
  static FarmItem createCrop({
    required String name,
    required String area,
    required DateTime plantedDate,
    required DateTime expectedHarvestDate,
    required double investment,
    required double expectedRevenue,
    CropStatus status = CropStatus.planted,
  }) {
    return FarmItem(
      name: name,
      type: FarmItemType.crop.toString().split('.').last,
      details: {
        'area': area,
        'plantedDate': plantedDate.toIso8601String(),
        'expectedHarvestDate': expectedHarvestDate.toIso8601String(),
        'cropStatus': status.toString().split('.').last,
        'investment': investment,
        'expectedRevenue': expectedRevenue,
      },
      createdDate: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
  }

  static FarmItem createLivestock({
    required String name,
    required int count,
    required String breed,
    required String age,
    required String monthlyYield,
    required double feedCost,
    required double revenue,
    LivestockHealthStatus healthStatus = LivestockHealthStatus.good,
  }) {
    return FarmItem(
      name: name,
      type: FarmItemType.livestock.toString().split('.').last,
      details: {
        'count': count,
        'breed': breed,
        'age': age,
        'healthStatus': healthStatus.toString().split('.').last,
        'monthlyYield': monthlyYield,
        'feedCost': feedCost,
        'revenue': revenue,
      },
      createdDate: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
  }
}
