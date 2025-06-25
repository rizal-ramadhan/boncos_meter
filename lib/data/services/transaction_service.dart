import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import 'auth_service.dart';

class TransactionService {
  static const String _storagePrefix = 'transactions_user_';
  final AuthService _authService = AuthService();

  // Get storage key for current user
  Future<String?> _getUserStorageKey() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) return null;
    return '$_storagePrefix${currentUser.id}';
  }

  // Get all transactions for current user
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final storageKey = await _getUserStorageKey();
      if (storageKey == null) {
        debugPrint('No current user found');
        return [];
      }

      final prefs = await SharedPreferences.getInstance();
      final String? transactionsJson = prefs.getString(storageKey);
      
      debugPrint('Loading transactions for user: $storageKey'); // Debug log
      debugPrint('Data: $transactionsJson'); // Debug log
      
      if (transactionsJson == null) {
        debugPrint('No saved transactions found for current user');
        return [];
      }

      final List<dynamic> transactionsList = json.decode(transactionsJson);
      final transactions = transactionsList
          .map((json) => TransactionModel.fromJson(json))
          .toList();
      
      debugPrint('Loaded ${transactions.length} transactions for current user');
      return transactions;
    } catch (e) {
      debugPrint('Error getting transactions: $e');
      return [];
    }
  }

  // Add new transaction for current user
  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      final transactions = await getTransactions();
      transactions.add(transaction);
      return await _saveTransactions(transactions);
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return false;
    }
  }

  // Update existing transaction for current user
  Future<bool> updateTransaction(TransactionModel updatedTransaction) async {
    try {
      final transactions = await getTransactions();
      final index = transactions.indexWhere((t) => t.id == updatedTransaction.id);
      
      if (index != -1) {
        transactions[index] = updatedTransaction;
        return await _saveTransactions(transactions);
      }
      return false;
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      return false;
    }
  }

  // Delete transaction for current user
  Future<bool> deleteTransaction(String transactionId) async {
    try {
      final transactions = await getTransactions();
      transactions.removeWhere((t) => t.id == transactionId);
      return await _saveTransactions(transactions);
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }

  // Get transactions by type for current user
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final transactions = await getTransactions();
    return transactions.where((t) => t.type == type).toList();
  }

  // Get income transactions for current user
  Future<List<TransactionModel>> getIncomeTransactions() async {
    return await getTransactionsByType('Income');
  }

  // Get expense transactions for current user
  Future<List<TransactionModel>> getExpenseTransactions() async {
    return await getTransactionsByType('Expense');
  }

  // Get total balance for current user
  Future<double> getTotalBalance() async {
    final transactions = await getTransactions();
    double balance = 0;
    
    for (final transaction in transactions) {
      if (transaction.isIncome) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    
    return balance;
  }

  // Get total income for current user
  Future<double> getTotalIncome() async {
    final incomeTransactions = await getIncomeTransactions();
    double total = 0.0;
    for (final transaction in incomeTransactions) {
      total += transaction.amount;
    }
    return total;
  }

  // Get total expense for current user
  Future<double> getTotalExpense() async {
    final expenseTransactions = await getExpenseTransactions();
    double total = 0.0;
    for (final transaction in expenseTransactions) {
      total += transaction.amount;
    }
    return total;
  }

  // Get recent transactions (last 5) for current user
  Future<List<TransactionModel>> getRecentTransactions() async {
    final transactions = await getTransactions();
    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return transactions.take(5).toList();
  }

  // Search transactions for current user
  Future<List<TransactionModel>> searchTransactions(String query) async {
    final transactions = await getTransactions();
    final lowercaseQuery = query.toLowerCase();
    
    return transactions.where((transaction) {
      return transaction.title.toLowerCase().contains(lowercaseQuery) ||
             transaction.tag.toLowerCase().contains(lowercaseQuery) ||
             transaction.note.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Clear all transactions for current user (for testing)
  Future<bool> clearAllTransactions() async {
    try {
      final storageKey = await _getUserStorageKey();
      if (storageKey == null) return false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
      debugPrint('Cleared all transactions for current user');
      return true;
    } catch (e) {
      debugPrint('Error clearing transactions: $e');
      return false;
    }
  }

  // Clear transactions for specific user (admin function)
  Future<bool> clearTransactionsForUser(String userId) async {
    try {
      final storageKey = '$_storagePrefix$userId';
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
      debugPrint('Cleared all transactions for user: $userId');
      return true;
    } catch (e) {
      debugPrint('Error clearing transactions for user $userId: $e');
      return false;
    }
  }

  // Get transaction count for current user
  Future<int> getTransactionCount() async {
    final transactions = await getTransactions();
    return transactions.length;
  }

  // Get transactions for date range (current user)
  Future<List<TransactionModel>> getTransactionsInDateRange(DateTime startDate, DateTime endDate) async {
    final transactions = await getTransactions();
    return transactions.where((transaction) {
      return transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Private method to save transactions to storage for current user
  Future<bool> _saveTransactions(List<TransactionModel> transactions) async {
    try {
      final storageKey = await _getUserStorageKey();
      if (storageKey == null) {
        debugPrint('Cannot save: No current user found');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = json.encode(
        transactions.map((t) => t.toJson()).toList(),
      );
      await prefs.setString(storageKey, transactionsJson);
      
      debugPrint('Saved ${transactions.length} transactions for user'); // Debug log
      debugPrint('Storage key: $storageKey'); // Debug log
      
      return true;
    } catch (e) {
      debugPrint('Error saving transactions: $e');
      return false;
    }
  }

  // Utility method to migrate old transactions to user-specific storage
  Future<bool> migrateOldTransactions() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return false;

      final prefs = await SharedPreferences.getInstance();
      const oldKey = 'transactions';
      final oldTransactionsJson = prefs.getString(oldKey);
      
      if (oldTransactionsJson == null) return true; // No old data to migrate
      
      final newStorageKey = '$_storagePrefix${currentUser.id}';
      final hasNewData = prefs.getString(newStorageKey);
      
      // Only migrate if user doesn't have new format data yet
      if (hasNewData == null) {
        await prefs.setString(newStorageKey, oldTransactionsJson);
        debugPrint('Migrated old transactions to user-specific storage');
      }
      
      // Remove old data after successful migration
      await prefs.remove(oldKey);
      return true;
    } catch (e) {
      debugPrint('Error migrating old transactions: $e');
      return false;
    }
  }
}