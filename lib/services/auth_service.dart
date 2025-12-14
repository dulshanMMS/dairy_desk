import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import 'db_service.dart';

class AuthService {
  static DbCollection? userCollection;
  static User? _currentUser;

  // Initialize auth service (call this after DB connection)
  static Future<void> initialize() async {
    if (DBService.database != null) {
      userCollection = DBService.database!.collection('users');
    }
  }

  // Hash password using SHA-256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Create default admin user if no users exist
  static Future<void> createDefaultUser() async {
    try {
      if (userCollection == null) {
        print('⚠️ Cannot create default user: Database not connected');
        return;
      }

      final userCount = await userCollection!.count();
      if (userCount == 0) {
        final defaultUser = User(
          email: 'admin@dairydesk.com',
          name: 'Admin User',
          phone: '',
          role: 'admin',
          createdDate: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        final userMap = defaultUser.toMap();
        userMap['passwordHash'] = _hashPassword('admin123'); // Default password
        userMap['isDefaultUser'] = true;

        await userCollection!.insertOne(userMap);
        print('✅ Default admin user created: admin@dairydesk.com / admin123');
      }
    } catch (e) {
      print('⚠️ Failed to create default user: $e');
    }
  }

  // Register new user
  static Future<User> registerUser({
    required String email,
    required String password,
    required String name,
    String phone = '',
    String role = 'owner',
  }) async {
    try {
      if (userCollection == null) {
        throw Exception('Database not connected. Cannot register user.');
      }

      // Check if user already exists
      final existingUser = await userCollection!.findOne(where.eq('email', email.toLowerCase()));
      if (existingUser != null) {
        throw Exception('User with this email already exists');
      }

      // Create new user
      final user = User(
        email: email.toLowerCase(),
        name: name,
        phone: phone,
        role: role,
        createdDate: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      final userMap = user.toMap();
      userMap['passwordHash'] = _hashPassword(password);

      final result = await userCollection!.insertOne(userMap);
      return user.copyWith(id: result.id.toString());
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  // Login user
  static Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      if (userCollection == null) {
        throw Exception('Database not connected. Cannot login.');
      }

      final userDoc = await userCollection!.findOne(where.eq('email', email.toLowerCase()));

      if (userDoc == null) {
        throw Exception('User not found');
      }

      final storedHash = userDoc['passwordHash'];
      final inputHash = _hashPassword(password);

      if (storedHash != inputHash) {
        throw Exception('Invalid password');
      }

      if (userDoc['isActive'] == false) {
        throw Exception('Account is deactivated');
      }

      // Update last login
      await userCollection!.updateOne(
        where.id(userDoc['_id']),
        modify.set('lastLogin', DateTime.now().toIso8601String()),
      );

      final user = User.fromMap(userDoc);
      _currentUser = user;

      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Logout user
  static Future<void> logout() async {
    _currentUser = null;
  }

  // Get current logged in user
  static User? getCurrentUser() {
    return _currentUser;
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _currentUser != null;
  }

  // Update user profile
  static Future<User> updateProfile({
    required String userId,
    String? name,
    String? phone,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      if (userCollection == null) {
        throw Exception('Database not connected');
      }

      final updateMap = <String, dynamic>{};
      if (name != null) updateMap['name'] = name;
      if (phone != null) updateMap['phone'] = phone;
      if (preferences != null) updateMap['preferences'] = preferences;

      if (updateMap.isEmpty) {
        throw Exception('No fields to update');
      }

      await userCollection!.updateOne(
        where.id(ObjectId.parse(userId)),
        modify.set('name', name)
            .set('phone', phone)
            .set('preferences', preferences),
      );

      // Get updated user
      final userDoc = await userCollection!.findOne(where.id(ObjectId.parse(userId)));
      if (userDoc == null) {
        throw Exception('User not found after update');
      }

      final updatedUser = User.fromMap(userDoc);
      if (_currentUser?.id == userId) {
        _currentUser = updatedUser;
      }

      return updatedUser;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Change password
  static Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (userCollection == null) {
        throw Exception('Database not connected');
      }

      final userDoc = await userCollection!.findOne(where.id(ObjectId.parse(userId)));
      if (userDoc == null) {
        throw Exception('User not found');
      }

      final currentHash = userDoc['passwordHash'];
      if (currentHash != _hashPassword(currentPassword)) {
        throw Exception('Current password is incorrect');
      }

      if (newPassword.length < 6) {
        throw Exception('New password must be at least 6 characters long');
      }

      await userCollection!.updateOne(
        where.id(ObjectId.parse(userId)),
        modify.set('passwordHash', _hashPassword(newPassword)),
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Reset password (for admin use)
  static Future<void> resetUserPassword({
    required String userEmail,
    required String newPassword,
  }) async {
    try {
      if (userCollection == null) {
        throw Exception('Database not connected');
      }

      final userDoc = await userCollection!.findOne(where.eq('email', userEmail.toLowerCase()));
      if (userDoc == null) {
        throw Exception('User not found');
      }

      await userCollection!.updateOne(
        where.id(userDoc['_id']),
        modify.set('passwordHash', _hashPassword(newPassword)),
      );
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  // Get all users (admin function)
  static Future<List<User>> getAllUsers() async {
    try {
      if (userCollection == null) {
        throw Exception('Database not connected');
      }

      final users = await userCollection!.find().toList();
      return users.map((userDoc) => User.fromMap(userDoc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  // Deactivate user
  static Future<void> deactivateUser(String userId) async {
    try {
      if (userCollection == null) {
        throw Exception('Database not connected');
      }

      await userCollection!.updateOne(
        where.id(ObjectId.parse(userId)),
        modify.set('isActive', false),
      );
    } catch (e) {
      throw Exception('Failed to deactivate user: $e');
    }
  }

  // Activate user
  static Future<void> activateUser(String userId) async {
    try {
      if (userCollection == null) {
        throw Exception('Database not connected');
      }

      await userCollection!.updateOne(
        where.id(ObjectId.parse(userId)),
        modify.set('isActive', true),
      );
    } catch (e) {
      throw Exception('Failed to activate user: $e');
    }
  }
}
