import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';

enum FarmItemType { crop, livestock, spice }

class FarmItem {
  final ObjectId? id;
  final String name;
  final FarmItemType type;
  final String? area; // For crops
  final DateTime? plantedDate;
  final DateTime? expectedHarvestDate;
  final String status;
  final double investment;
  final double expectedRevenue;
  final IconData icon;
  final Color color;
  final DateTime date;

  FarmItem({
    this.id,
    required this.name,
    required this.type,
    this.area,
    this.plantedDate,
    this.expectedHarvestDate,
    this.status = 'Active',
    required this.investment,
    required this.expectedRevenue,
    this.icon = Icons.agriculture,
    this.color = const Color(0xFF4CAF50),
    DateTime? date,
  }) : date = date ?? DateTime.now();

  factory FarmItem.fromMap(Map<String, dynamic> map) {
    return FarmItem(
      id: map['_id'] as ObjectId?,
      name: map['name'] as String,
      type: FarmItemType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => FarmItemType.crop,
      ),
      area: map['area'] as String?,
      plantedDate: map['plantedDate'] != null 
          ? (map['plantedDate'] is String 
              ? DateTime.parse(map['plantedDate']) 
              : map['plantedDate'] as DateTime)
          : null,
      expectedHarvestDate: map['expectedHarvestDate'] != null
          ? (map['expectedHarvestDate'] is String
              ? DateTime.parse(map['expectedHarvestDate'])
              : map['expectedHarvestDate'] as DateTime)
          : null,
      status: map['status'] as String? ?? 'Active',
      investment: (map['investment'] as num).toDouble(),
      expectedRevenue: (map['expectedRevenue'] as num).toDouble(),
      icon: _getIconFromCode(map['iconCode'] as int? ?? Icons.agriculture.codePoint),
      color: Color(map['colorValue'] as int? ?? 0xFF4CAF50),
      date: map['date'] is String 
          ? DateTime.parse(map['date']) 
          : map['date'] as DateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'area': area,
      'plantedDate': plantedDate?.toIso8601String(),
      'expectedHarvestDate': expectedHarvestDate?.toIso8601String(),
      'status': status,
      'investment': investment,
      'expectedRevenue': expectedRevenue,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
      'date': date.toIso8601String(),
    };
  }

  FarmItem copyWith({
    ObjectId? id,
    String? name,
    FarmItemType? type,
    String? area,
    DateTime? plantedDate,
    DateTime? expectedHarvestDate,
    String? status,
    double? investment,
    double? expectedRevenue,
    IconData? icon,
    Color? color,
    DateTime? date,
  }) {
    return FarmItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      area: area ?? this.area,
      plantedDate: plantedDate ?? this.plantedDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      status: status ?? this.status,
      investment: investment ?? this.investment,
      expectedRevenue: expectedRevenue ?? this.expectedRevenue,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      date: date ?? this.date,
    );
  }

  double get expectedProfit {
    return expectedRevenue - investment;
  }

  static IconData _getIconFromCode(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  @override
  String toString() {
    return 'FarmItem{id: $id, name: $name, type: $type, investment: $investment, expectedRevenue: $expectedRevenue}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FarmItem &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.investment == investment &&
        other.expectedRevenue == expectedRevenue;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        investment.hashCode ^
        expectedRevenue.hashCode;
  }
}
