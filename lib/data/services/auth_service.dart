import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Hash password for security
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register new user
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Get existing users
      final users = await _getUsers();
      
      // Check if email already exists
      if (users.any((user) => user.email.toLowerCase() == email.toLowerCase())) {
        return AuthResult(
          success: false,
          message: 'Email already registered',
        );
      }
      
      // Create new user
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email.toLowerCase(),
        createdAt: DateTime.now(),
      );
      
      // Add user to list
      users.add(newUser);
      
      // Save users list
      await _saveUsers(users);
      
      // Save password separately (hashed)
      await _saveUserPassword(newUser.id, password);
      
      debugPrint('User registered successfully: ${newUser.email}');
      
      return AuthResult(
        success: true,
        message: 'Registration successful',
        user: newUser,
      );
    } catch (e) {
      debugPrint('Error registering user: $e');
      return AuthResult(
        success: false,
        message: 'Registration failed. Please try again.',
      );
    }
  }

  // Login user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final users = await _getUsers();
      
      // Find user by email
      final user = users.cast<UserModel?>().firstWhere(
        (user) => user?.email.toLowerCase() == email.toLowerCase(),
        orElse: () => null,
      );
      
      if (user == null) {
        return AuthResult(
          success: false,
          message: 'Email not found',
        );
      }
      
      // Verify password
      final isPasswordCorrect = await _verifyPassword(user.id, password);
      
      if (!isPasswordCorrect) {
        return AuthResult(
          success: false,
          message: 'Invalid password',
        );
      }
      
      // Update last login
      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
      await _updateUser(updatedUser);
      
      // Save login state
      await _saveCurrentUser(updatedUser);
      
      debugPrint('User logged in successfully: ${updatedUser.email}');
      
      return AuthResult(
        success: true,
        message: 'Login successful',
        user: updatedUser,
      );
    } catch (e) {
      debugPrint('Error logging in user: $e');
      return AuthResult(
        success: false,
        message: 'Login failed. Please try again.',
      );
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      await prefs.setBool(_isLoggedInKey, false);
      
      debugPrint('User logged out successfully');
      return true;
    } catch (e) {
      debugPrint('Error logging out user: $e');
      return false;
    }
  }

  // Get current logged in user
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (!isLoggedIn) return null;
      
      final userJson = prefs.getString(_currentUserKey);
      if (userJson == null) return null;
      
      final userMap = json.decode(userJson);
      return UserModel.fromJson(userMap);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      final users = await _getUsers();
      final userIndex = users.indexWhere((user) => user.id == userId);
      
      if (userIndex == -1) return false;
      
      // Check if new email conflicts with other users
      final emailExists = users.any((user) => 
          user.id != userId && 
          user.email.toLowerCase() == email.toLowerCase());
      
      if (emailExists) return false;
      
      // Update user
      final updatedUser = users[userIndex].copyWith(
        name: name,
        email: email.toLowerCase(),
      );
      
      users[userIndex] = updatedUser;
      await _saveUsers(users);
      
      // Update current user if it's the same user
      final currentUser = await getCurrentUser();
      if (currentUser?.id == userId) {
        await _saveCurrentUser(updatedUser);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Verify current password
      final isCurrentPasswordCorrect = await _verifyPassword(userId, currentPassword);
      if (!isCurrentPasswordCorrect) return false;
      
      // Save new password
      await _saveUserPassword(userId, newPassword);
      
      return true;
    } catch (e) {
      debugPrint('Error changing password: $e');
      return false;
    }
  }

  // Delete user account and all associated data
  Future<DeleteAccountResult> deleteAccount({
    required String userId,
    required String password,
  }) async {
    try {
      // Verify password first
      final isPasswordCorrect = await _verifyPassword(userId, password);
      if (!isPasswordCorrect) {
        return DeleteAccountResult(
          success: false,
          message: 'Invalid password',
        );
      }

      // Get current user to check if deleting own account
      final currentUser = await getCurrentUser();
      final isDeletingOwnAccount = currentUser?.id == userId;

      // Remove user from users list
      final users = await _getUsers();
      final userToDelete = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception('User not found'),
      );
      
      users.removeWhere((user) => user.id == userId);
      await _saveUsers(users);

      // Delete user password
      await _deleteUserPassword(userId);

      // Delete user-specific data
      await _deleteUserData(userId);

      // If user is deleting their own account, logout
      if (isDeletingOwnAccount) {
        await logout();
      }

      debugPrint('User account deleted successfully: ${userToDelete.email}');
      
      return DeleteAccountResult(
        success: true,
        message: 'Account deleted successfully',
        wasOwnAccount: isDeletingOwnAccount,
      );
    } catch (e) {
      debugPrint('Error deleting user account: $e');
      return DeleteAccountResult(
        success: false,
        message: 'Failed to delete account. Please try again.',
      );
    }
  }

  // Verify password for account deletion
  Future<bool> verifyPasswordForDeletion({
    required String userId,
    required String password,
  }) async {
    try {
      return await _verifyPassword(userId, password);
    } catch (e) {
      debugPrint('Error verifying password for deletion: $e');
      return false;
    }
  }

  // Get all users (admin function)
  Future<List<UserModel>> getAllUsers() async {
    try {
      return await _getUsers();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  // Private methods
  Future<List<UserModel>> _getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      
      if (usersJson == null) return [];
      
      final usersList = json.decode(usersJson) as List<dynamic>;
      return usersList.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting users: $e');
      return [];
    }
  }

  Future<bool> _saveUsers(List<UserModel> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = json.encode(users.map((user) => user.toJson()).toList());
      await prefs.setString(_usersKey, usersJson);
      return true;
    } catch (e) {
      debugPrint('Error saving users: $e');
      return false;
    }
  }

  Future<bool> _saveCurrentUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_currentUserKey, userJson);
      await prefs.setBool(_isLoggedInKey, true);
      return true;
    } catch (e) {
      debugPrint('Error saving current user: $e');
      return false;
    }
  }

  Future<bool> _updateUser(UserModel updatedUser) async {
    try {
      final users = await _getUsers();
      final userIndex = users.indexWhere((user) => user.id == updatedUser.id);
      
      if (userIndex == -1) return false;
      
      users[userIndex] = updatedUser;
      return await _saveUsers(users);
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  Future<bool> _saveUserPassword(String userId, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hashedPassword = _hashPassword(password);
      await prefs.setString('password_$userId', hashedPassword);
      return true;
    } catch (e) {
      debugPrint('Error saving user password: $e');
      return false;
    }
  }

  Future<bool> _verifyPassword(String userId, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPassword = prefs.getString('password_$userId');
      
      if (savedPassword == null) return false;
      
      final hashedPassword = _hashPassword(password);
      return savedPassword == hashedPassword;
    } catch (e) {
      debugPrint('Error verifying password: $e');
      return false;
    }
  }

  Future<bool> _deleteUserPassword(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('password_$userId');
      debugPrint('Deleted password for user: $userId');
      return true;
    } catch (e) {
      debugPrint('Error deleting user password: $e');
      return false;
    }
  }

  Future<bool> _deleteUserData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Delete user transactions
      final transactionKey = 'transactions_user_$userId';
      await prefs.remove(transactionKey);
      debugPrint('Deleted transactions for user: $userId');
      
      // Delete user currency preference
      final currencyKey = 'selected_currency_user_$userId';
      await prefs.remove(currencyKey);
      debugPrint('Deleted currency preference for user: $userId');
      
      // Delete any other user-specific data
      // Add more data deletion here if needed
      
      return true;
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      return false;
    }
  }
}

// Auth result class
class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}

// Delete account result class
class DeleteAccountResult {
  final bool success;
  final String message;
  final bool wasOwnAccount;

  DeleteAccountResult({
    required this.success,
    required this.message,
    this.wasOwnAccount = false,
  });
}