import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/transaction_service.dart';
import '../../data/services/currency_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TransactionService _transactionService = TransactionService();
  final CurrencyService _currencyService = CurrencyService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
        
        // Migrate old data to user-specific storage if needed
        if (_currentUser != null) {
          await _migrateUserData();
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Register user
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      
      if (result.success && result.user != null) {
        _currentUser = result.user;
        _isLoggedIn = true;
        await _authService.logout(); // Don't auto login after register
        _isLoggedIn = false;
        _currentUser = null;
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      debugPrint('Error in register: $e');
      return AuthResult(
        success: false,
        message: 'Registration failed. Please try again.',
      );
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );
      
      if (result.success && result.user != null) {
        _currentUser = result.user;
        _isLoggedIn = true;
        
        // Migrate old data to user-specific storage if needed
        await _migrateUserData();
        
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      debugPrint('Error in login: $e');
      return AuthResult(
        success: false,
        message: 'Login failed. Please try again.',
      );
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<bool> logout() async {
    _setLoading(true);
    try {
      final success = await _authService.logout();
      if (success) {
        _currentUser = null;
        _isLoggedIn = false;
        
        // Clear cached data when logging out
        _clearCachedData();
        
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error in logout: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    try {
      final success = await _authService.updateUserProfile(
        userId: _currentUser!.id,
        name: name,
        email: email,
      );
      
      if (success) {
        _currentUser = _currentUser!.copyWith(
          name: name,
          email: email,
        );
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    try {
      final success = await _authService.changePassword(
        userId: _currentUser!.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      return success;
    } catch (e) {
      debugPrint('Error changing password: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<DeleteAccountResult> deleteAccount({
    required String password,
  }) async {
    if (_currentUser == null) {
      return DeleteAccountResult(
        success: false,
        message: 'No user logged in',
      );
    }
    
    _setLoading(true);
    try {
      final result = await _authService.deleteAccount(
        userId: _currentUser!.id,
        password: password,
      );
      
      if (result.success) {
        // Clear current user state
        _currentUser = null;
        _isLoggedIn = false;
        _clearCachedData();
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return DeleteAccountResult(
        success: false,
        message: 'Failed to delete account. Please try again.',
      );
    } finally {
      _setLoading(false);
    }
  }

  // Verify password for account deletion
  Future<bool> verifyPasswordForDeletion({
    required String password,
  }) async {
    if (_currentUser == null) return false;
    
    try {
      return await _authService.verifyPasswordForDeletion(
        userId: _currentUser!.id,
        password: password,
      );
    } catch (e) {
      debugPrint('Error verifying password for deletion: $e');
      return false;
    }
  }

  // Switch user (for testing - clear current data and set new user)
  Future<void> switchUser(UserModel newUser) async {
    _setLoading(true);
    try {
      _currentUser = newUser;
      _isLoggedIn = true;
      
      // Clear any cached data and load new user's data
      _clearCachedData();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error switching user: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear cached data when switching users
  void _clearCachedData() {
    // This will trigger providers to reload their data for the new user
    debugPrint('Clearing cached data for user switch');
  }

  // Migrate old data to user-specific storage
  Future<void> _migrateUserData() async {
    try {
      // Migrate transactions
      await _transactionService.migrateOldTransactions();
      
      // Migrate currency preference
      await _currencyService.migrateOldCurrency();
      
      debugPrint('User data migration completed');
    } catch (e) {
      debugPrint('Error during user data migration: $e');
    }
  }

  // Get user statistics (for profile screen)
  Future<Map<String, dynamic>> getUserStatistics() async {
    if (_currentUser == null) return {};
    
    try {
      final transactionCount = await _transactionService.getTransactionCount();
      final totalBalance = await _transactionService.getTotalBalance();
      final totalIncome = await _transactionService.getTotalIncome();
      final totalExpense = await _transactionService.getTotalExpense();
      
      return {
        'transactionCount': transactionCount,
        'totalBalance': totalBalance,
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'memberSince': _currentUser!.createdAt,
        'lastLogin': _currentUser!.lastLoginAt,
      };
    } catch (e) {
      debugPrint('Error getting user statistics: $e');
      return {};
    }
  }
}