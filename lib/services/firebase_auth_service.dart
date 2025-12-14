import 'package:firebase_auth/firebase_auth.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/user.dart' as app_user;
import 'db_service.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static User? get currentFirebaseUser => _auth.currentUser;
  static app_user.User? _currentAppUser;

  // Listen to auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Initialize Firebase Auth
  static Future<void> initialize() async {
    // Check if user is already logged in
    if (_auth.currentUser != null) {
      await _loadUserData(_auth.currentUser!.uid);
    }
  }

  // Sign up with email and password
  static Future<app_user.User> signUp({
    required String email,
    required String password,
    required String name,
    String phone = '',
  }) async {
    try {
      // Create Firebase user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Create user in MongoDB
      final appUser = app_user.User(
        id: userCredential.user!.uid,
        email: email.toLowerCase(),
        name: name,
        phone: phone,
        role: 'owner',
        createdDate: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Save to MongoDB if connected
      if (DBService.userCollection != null) {
        await DBService.userCollection!.insertOne({
          '_id': userCredential.user!.uid,
          'email': appUser.email,
          'name': appUser.name,
          'phone': appUser.phone,
          'role': appUser.role,
          'isActive': true,
          'createdDate': appUser.createdDate.toIso8601String(),
          'lastLogin': appUser.lastLogin.toIso8601String(),
        });
      }

      _currentAppUser = appUser;
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with email and password
  static Future<app_user.User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Load or create user data in MongoDB
      await _loadUserData(userCredential.user!.uid);

      // Update last login if DB is connected
      if (DBService.userCollection != null) {
        await DBService.userCollection!.updateOne(
          {'_id': userCredential.user!.uid},
          {
            '\$set': {'lastLogin': DateTime.now().toIso8601String()}
          },
        );
      }

      return _currentAppUser!;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
    _currentAppUser = null;
  }

  // Get current app user
  static app_user.User? getCurrentUser() {
    return _currentAppUser;
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _auth.currentUser != null && _currentAppUser != null;
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  // Update user profile
  static Future<app_user.User> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Update Firebase display name
      if (name != null) {
        await user.updateDisplayName(name);
      }

      // Update MongoDB user data if connected
      if (DBService.userCollection != null) {
        final updateMap = <String, dynamic>{};
        if (name != null) updateMap['name'] = name;
        if (phone != null) updateMap['phone'] = phone;

        if (updateMap.isNotEmpty) {
          await DBService.userCollection!.updateOne(
            {'_id': user.uid},
            {'\$set': updateMap},
          );
        }
      }

      // Reload user data
      await _loadUserData(user.uid);
      return _currentAppUser!;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Change password
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  // Load user data from MongoDB
  static Future<void> _loadUserData(String uid) async {
    try {
      if (DBService.userCollection == null) {
        // Create user from Firebase data only
        final firebaseUser = _auth.currentUser!;
        _currentAppUser = app_user.User(
          id: uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          phone: firebaseUser.phoneNumber ?? '',
          role: 'owner',
          createdDate: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        return;
      }

      final result = await DBService.userCollection!.findOne(where.eq('_id', uid));

      if (result == null) {
        // Create new user record if doesn't exist
        final firebaseUser = _auth.currentUser!;
        _currentAppUser = app_user.User(
          id: uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          phone: firebaseUser.phoneNumber ?? '',
          role: 'owner',
          createdDate: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await DBService.userCollection!.insertOne({
          '_id': uid,
          'email': _currentAppUser!.email,
          'name': _currentAppUser!.name,
          'phone': _currentAppUser!.phone,
          'role': _currentAppUser!.role,
          'isActive': true,
          'createdDate': _currentAppUser!.createdDate.toIso8601String(),
          'lastLogin': _currentAppUser!.lastLogin.toIso8601String(),
        });
      } else {
        _currentAppUser = app_user.User.fromMap(result as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error loading user data: $e');
      rethrow;
    }
  }

  // Handle Firebase Auth exceptions
  static String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign in is not enabled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  // Delete account
  static Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete from MongoDB if connected
      if (DBService.userCollection != null) {
        await DBService.userCollection!.deleteOne({'_id': user.uid});
      }

      // Delete Firebase account
      await user.delete();
      _currentAppUser = null;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }
}
