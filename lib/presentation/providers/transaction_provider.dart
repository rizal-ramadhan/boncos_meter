import 'package:flutter/foundation.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/transaction_service.dart';
import 'auth_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String _searchQuery = '';
  AuthProvider? _authProvider;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Set auth provider reference to listen for user changes
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    _authProvider?.addListener(_onUserChanged);
  }

  // Dispose method to clean up listeners
  @override
  void dispose() {
    _authProvider?.removeListener(_onUserChanged);
    super.dispose();
  }

  // Handle user changes (login/logout/switch)
  void _onUserChanged() {
    if (_authProvider?.isLoggedIn == true) {
      // User logged in or switched - reload transactions
      debugPrint('User changed - reloading transactions');
      loadTransactions();
    } else {
      // User logged out - clear transactions
      debugPrint('User logged out - clearing transactions');
      _transactions.clear();
      _searchQuery = '';
      notifyListeners();
    }
  }

  // Filtered transactions
  List<TransactionModel> get incomeTransactions =>
      _transactions.where((t) => t.isIncome).toList();

  List<TransactionModel> get expenseTransactions =>
      _transactions.where((t) => t.isExpense).toList();

  List<TransactionModel> get recentTransactions {
    final sorted = List<TransactionModel>.from(_transactions);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  List<TransactionModel> get filteredTransactions {
    if (_searchQuery.isEmpty) {
      return _transactions;
    }
    final query = _searchQuery.toLowerCase();
    return _transactions.where((transaction) {
      return transaction.title.toLowerCase().contains(query) ||
             transaction.tag.toLowerCase().contains(query) ||
             transaction.note.toLowerCase().contains(query);
    }).toList();
  }

  // Financial calculations
  double get totalBalance {
    double balance = 0;
    for (final transaction in _transactions) {
      if (transaction.isIncome) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    return balance;
  }

  double get totalIncome {
    return incomeTransactions.fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return expenseTransactions.fold(0, (sum, t) => sum + t.amount);
  }

  // Load all transactions for current user
  Future<void> loadTransactions() async {
    // Check if user is logged in
    if (_authProvider?.isLoggedIn != true) {
      debugPrint('Cannot load transactions: No user logged in');
      _transactions.clear();
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      _transactions = await _transactionService.getTransactions();
      debugPrint('Loaded ${_transactions.length} transactions for current user');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add transaction
  Future<bool> addTransaction({
    required String title,
    required double amount,
    required String type,
    required String tag,
    required DateTime date,
    required String note,
  }) async {
    // Check if user is logged in
    if (_authProvider?.isLoggedIn != true) {
      debugPrint('Cannot add transaction: No user logged in');
      return false;
    }

    _setLoading(true);
    try {
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        type: type,
        tag: tag,
        date: date,
        note: note,
        createdAt: DateTime.now(),
      );

      final success = await _transactionService.addTransaction(transaction);
      if (success) {
        _transactions.add(transaction);
        notifyListeners();
        debugPrint('Added transaction for current user: ${transaction.title}');
      }
      return success;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update transaction
  Future<bool> updateTransaction(TransactionModel updatedTransaction) async {
    // Check if user is logged in
    if (_authProvider?.isLoggedIn != true) {
      debugPrint('Cannot update transaction: No user logged in');
      return false;
    }

    _setLoading(true);
    try {
      final success = await _transactionService.updateTransaction(updatedTransaction);
      if (success) {
        final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
        if (index != -1) {
          _transactions[index] = updatedTransaction;
          notifyListeners();
          debugPrint('Updated transaction for current user: ${updatedTransaction.title}');
        }
      }
      return success;
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(String transactionId) async {
    // Check if user is logged in
    if (_authProvider?.isLoggedIn != true) {
      debugPrint('Cannot delete transaction: No user logged in');
      return false;
    }

    _setLoading(true);
    try {
      final success = await _transactionService.deleteTransaction(transactionId);
      if (success) {
        _transactions.removeWhere((t) => t.id == transactionId);
        notifyListeners();
        debugPrint('Deleted transaction for current user: $transactionId');
      }
      return success;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search transactions
  void searchTransactions(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Clear all transactions for current user (for testing)
  Future<bool> clearAllTransactions() async {
    // Check if user is logged in
    if (_authProvider?.isLoggedIn != true) {
      debugPrint('Cannot clear transactions: No user logged in');
      return false;
    }

    _setLoading(true);
    try {
      final success = await _transactionService.clearAllTransactions();
      if (success) {
        _transactions.clear();
        notifyListeners();
        debugPrint('Cleared all transactions for current user');
      }
      return success;
    } catch (e) {
      debugPrint('Error clearing transactions: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get transaction by ID
  TransactionModel? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get transactions by date range
  List<TransactionModel> getTransactionsByDateRange(DateTime startDate, DateTime endDate) {
    return _transactions.where((transaction) {
      return transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Get transactions by tag
  List<TransactionModel> getTransactionsByTag(String tag) {
    return _transactions.where((t) => t.tag.toLowerCase() == tag.toLowerCase()).toList();
  }

  // Get transactions by type and date range
  List<TransactionModel> getTransactionsByTypeAndDateRange(
    String type, 
    DateTime startDate, 
    DateTime endDate
  ) {
    return _transactions.where((transaction) {
      return transaction.type == type &&
             transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Get monthly summary
  Map<String, double> getMonthlySummary(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    
    final monthlyTransactions = getTransactionsByDateRange(startDate, endDate);
    
    double income = 0;
    double expense = 0;
    
    for (final transaction in monthlyTransactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }
    
    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
      'count': monthlyTransactions.length.toDouble(),
    };
  }

  // Get spending by category/tag
  Map<String, double> getSpendingByTag() {
    final Map<String, double> tagSpending = {};
    
    for (final transaction in expenseTransactions) {
      tagSpending[transaction.tag] = (tagSpending[transaction.tag] ?? 0) + transaction.amount;
    }
    
    return tagSpending;
  }

  // Get income by category/tag
  Map<String, double> getIncomeByTag() {
    final Map<String, double> tagIncome = {};
    
    for (final transaction in incomeTransactions) {
      tagIncome[transaction.tag] = (tagIncome[transaction.tag] ?? 0) + transaction.amount;
    }
    
    return tagIncome;
  }

  // Refresh data (useful when user switches or data changes externally)
  Future<void> refreshData() async {
    debugPrint('Refreshing transaction data');
    await loadTransactions();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}