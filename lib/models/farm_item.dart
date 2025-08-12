enum FarmItemType { crop, livestock }

enum CropStatus { planted, growing, ready, harvested }

enum LivestockHealthStatus { excellent, good, fair, poor }

class FarmItem {
  final String? id;
  final String name;
  final FarmItemType type;
  final Map<String, dynamic> details;
  final DateTime createdDate;
  final DateTime? lastUpdated;

  FarmItem({
    this.id,
    required this.name,
    required this.type,
    required this.details,
    required this.createdDate,
    this.lastUpdated,
  });

  factory FarmItem.fromMap(Map<String, dynamic> map) {
    return FarmItem(
      id: map['_id']?.toString(),
      name: map['name'] ?? '',
      type: FarmItemType.values.firstWhere(
            (e) => e.toString().split('.').last == map['type'],
        orElse: () => FarmItemType.crop,
      ),
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      createdDate: DateTime.parse(map['createdDate'] ?? DateTime.now().toIso8601String()),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.toString().split('.').last,
      'details': details,
      'createdDate': createdDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // Crop-specific getters
  String? get area => type == FarmItemType.crop ? details['area'] : null;
  DateTime? get plantedDate => type == FarmItemType.crop && details['plantedDate'] != null
      ? DateTime.parse(details['plantedDate'])
      : null;
  DateTime? get expectedHarvestDate => type == FarmItemType.crop && details['expectedHarvestDate'] != null
      ? DateTime.parse(details['expectedHarvestDate'])
      : null;
  CropStatus? get cropStatus => type == FarmItemType.crop
      ? CropStatus.values.firstWhere(
        (e) => e.toString().split('.').last == details['status'],
    orElse: () => CropStatus.planted,
  )
      : null;
  double? get investment => details['investment']?.toDouble();
  double? get expectedRevenue => details['expectedRevenue']?.toDouble();

  // Livestock-specific getters
  int? get count => type == FarmItemType.livestock ? details['count'] : null;
  String? get breed => type == FarmItemType.livestock ? details['breed'] : null;
  String? get age => type == FarmItemType.livestock ? details['age'] : null;
  LivestockHealthStatus? get healthStatus => type == FarmItemType.livestock
      ? LivestockHealthStatus.values.firstWhere(
        (e) => e.toString().split('.').last == details['healthStatus'],
    orElse: () => LivestockHealthStatus.good,
  )
      : null;
  String? get monthlyYield => type == FarmItemType.livestock ? details['monthlyYield'] : null;
  double? get feedCost => type == FarmItemType.livestock ? details['feedCost']?.toDouble() : null;
  double? get revenue => type == FarmItemType.livestock ? details['revenue']?.toDouble() : null;

  // Common calculations
  double get profit {
    if (type == FarmItemType.crop) {
      return (expectedRevenue ?? 0) - (investment ?? 0);
    } else {
      return (revenue ?? 0) - (feedCost ?? 0);
    }
  }

  FarmItem copyWith({
    String? id,
    String? name,
    FarmItemType? type,
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

  @override
  String toString() {
    return 'FarmItem(id: $id, name: $name, type: $type, details: $details)';
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
      type: FarmItemType.crop,
      details: {
        'area': area,
        'plantedDate': plantedDate.toIso8601String(),
        'expectedHarvestDate': expectedHarvestDate.toIso8601String(),
        'status': status.toString().split('.').last,
        'investment': investment,
        'expectedRevenue': expectedRevenue,
      },
      createdDate: DateTime.now(),
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
      type: FarmItemType.livestock,
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
    );
  }
}