import 'package:mongo_dart/mongo_dart.dart';

class Shop {
  final ObjectId? id;
  final String name;
  final String ownerName;
  final String? phone;
  final String? address;
  final String? email;
  final DateTime createdDate;
  final bool isActive;

  Shop({
    this.id,
    required this.name,
    required this.ownerName,
    this.phone,
    this.address,
    this.email,
    DateTime? createdDate,
    this.isActive = true,
  }) : createdDate = createdDate ?? DateTime.now();

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['_id'] as ObjectId?,
      name: map['name'] as String,
      ownerName: map['ownerName'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      email: map['email'] as String?,
      createdDate: map['createdDate'] is String
          ? DateTime.parse(map['createdDate'])
          : map['createdDate'] as DateTime,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'ownerName': ownerName,
      'phone': phone,
      'address': address,
      'email': email,
      'createdDate': createdDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  Shop copyWith({
    ObjectId? id,
    String? name,
    String? ownerName,
    String? phone,
    String? address,
    String? email,
    DateTime? createdDate,
    bool? isActive,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      createdDate: createdDate ?? this.createdDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Shop{id: $id, name: $name, ownerName: $ownerName, phone: $phone, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Shop &&
        other.id == id &&
        other.name == name &&
        other.ownerName == ownerName &&
        other.phone == phone &&
        other.address == address &&
        other.email == email &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        ownerName.hashCode ^
        phone.hashCode ^
        address.hashCode ^
        email.hashCode ^
        isActive.hashCode;
  }
}
