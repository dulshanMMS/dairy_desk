class User {
  final String? id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final bool isActive;
  final DateTime createdDate;
  final DateTime lastLogin;
  final Map<String, dynamic>? preferences;

  User({
    this.id,
    required this.email,
    required this.name,
    this.phone = '',
    this.role = 'owner',
    this.isActive = true,
    required this.createdDate,
    required this.lastLogin,
    this.preferences,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? role,
    bool? isActive,
    DateTime? createdDate,
    DateTime? lastLogin,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdDate: createdDate ?? this.createdDate,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      'createdDate': createdDate.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'preferences': preferences,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id']?.toString(),
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'owner',
      isActive: map['isActive'] ?? true,
      createdDate: DateTime.parse(map['createdDate']),
      lastLogin: DateTime.parse(map['lastLogin']),
      preferences: map['preferences'],
    );
  }
}
