class Shop {
  final String? id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String ownerName;
  final DateTime createdDate;
  final bool isActive;
  final Map<String, dynamic> settings;

  Shop({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.ownerName,
    required this.createdDate,
    this.isActive = true,
    this.settings = const {},
  });

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['_id']?.toString(),
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      ownerName: map['ownerName'] ?? '',
      createdDate: DateTime.parse(map['createdDate'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'ownerName': ownerName,
      'createdDate': createdDate.toIso8601String(),
      'isActive': isActive,
      'settings': settings,
    };
  }

  Shop copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? ownerName,
    DateTime? createdDate,
    bool? isActive,
    Map<String, dynamic>? settings,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      ownerName: ownerName ?? this.ownerName,
      createdDate: createdDate ?? this.createdDate,
      isActive: isActive ?? this.isActive,
      settings: settings ?? this.settings,
    );
  }

  @override
  String toString() {
    return 'Shop(id: $id, name: $name, ownerName: $ownerName, isActive: $isActive)';
  }
}