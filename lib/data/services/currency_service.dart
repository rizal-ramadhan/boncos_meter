import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency_model.dart';
import 'auth_service.dart';

class CurrencyService {
  static const String _currencyPrefix = 'selected_currency_user_';
  final AuthService _authService = AuthService();

  // Get storage key for current user
  Future<String?> _getUserCurrencyKey() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) return null;
    return '$_currencyPrefix${currentUser.id}';
  }

  // Get selected currency for current user
  Future<CurrencyModel> getSelectedCurrency() async {
    try {
      final currencyKey = await _getUserCurrencyKey();
      if (currencyKey == null) {
        // Return default currency if no user logged in
        return CurrencyModel.getCurrencyByCode('IDR') ?? 
               CurrencyModel.supportedCurrencies.first;
      }

      final prefs = await SharedPreferences.getInstance();
      final currencyJson = prefs.getString(currencyKey);
      
      debugPrint('Loading currency for user: $currencyKey');
      
      if (currencyJson == null) {
        // Return default currency (IDR) if none selected for this user
        final defaultCurrency = CurrencyModel.getCurrencyByCode('IDR') ?? 
                               CurrencyModel.supportedCurrencies.first;
        
        // Save default currency for this user
        await setSelectedCurrency(defaultCurrency);
        return defaultCurrency;
      }

      final currencyMap = json.decode(currencyJson);
      final currency = CurrencyModel.fromJson(currencyMap);
      debugPrint('Loaded currency for user: ${currency.code}');
      return currency;
    } catch (e) {
      debugPrint('Error getting selected currency: $e');
      // Return default currency on error
      return CurrencyModel.getCurrencyByCode('IDR') ?? 
             CurrencyModel.supportedCurrencies.first;
    }
  }

  // Set selected currency for current user
  Future<bool> setSelectedCurrency(CurrencyModel currency) async {
    try {
      final currencyKey = await _getUserCurrencyKey();
      if (currencyKey == null) {
        debugPrint('Cannot save currency: No current user found');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final currencyJson = json.encode(currency.toJson());
      await prefs.setString(currencyKey, currencyJson);
      
      debugPrint('Currency updated for user: ${currency.code} (${currency.name})');
      debugPrint('Storage key: $currencyKey');
      return true;
    } catch (e) {
      debugPrint('Error setting selected currency: $e');
      return false;
    }
  }

  // Get all supported currencies
  List<CurrencyModel> getSupportedCurrencies() {
    return CurrencyModel.supportedCurrencies;
  }

  // Format amount with selected currency using proper locale formatting
  Future<String> formatAmount(double amount, {int decimalDigits = 2}) async {
    final currency = await getSelectedCurrency();
    
    // Handle special formatting for specific currencies
    switch (currency.code) {
      case 'IDR':
        // Indonesian Rupiah: Rp 1.000.000 (using dots as thousand separator)
        if (decimalDigits == 0) {
          return 'Rp ${_formatWithDots(amount.round())}';
        } else {
          return 'Rp ${_formatWithDots(amount.round())}'; // IDR doesn't use decimal in practice
        }
        
      case 'JPY':
      case 'KRW':
        // Japanese Yen and Korean Won don't use decimals
        return '${currency.symbol}${_formatWithCommas(amount.round())}';
        
      case 'EUR':
        // Euro: €1,000.00 or 1.000,00 € (depends on country, we'll use international format)
        if (decimalDigits == 0) {
          return '€${_formatWithCommas(amount.round())}';
        } else {
          return '€${_formatWithCommas(amount)}';
        }
        
      case 'INR':
        // Indian Rupee: ₹1,00,000 (uses lakh system, but we'll use standard for simplicity)
        if (decimalDigits == 0) {
          return '₹${_formatWithCommas(amount.round())}';
        } else {
          return '₹${_formatWithCommas(amount)}';
        }
        
      case 'CNY':
        // Chinese Yuan: ¥1,000
        if (decimalDigits == 0) {
          return '¥${_formatWithCommas(amount.round())}';
        } else {
          return '¥${_formatWithCommas(amount)}';
        }
        
      default:
        // Standard formatting for USD, GBP, CAD, AUD, etc.
        if (decimalDigits == 0) {
          return '${currency.symbol}${_formatWithCommas(amount.round())}';
        } else {
          return '${currency.symbol}${_formatWithCommas(amount)}';
        }
    }
  }
  
  // Helper method for formatting with commas (US style: 1,000.00)
  String _formatWithCommas(dynamic amount) {
    if (amount is int) {
      return amount.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), 
        (Match match) => '${match[1]},',
      );
    } else {
      // For double values
      final parts = amount.toStringAsFixed(2).split('.');
      final integerPart = parts[0].replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), 
        (Match match) => '${match[1]},',
      );
      return '$integerPart.${parts[1]}';
    }
  }
  
  // Helper method for formatting with dots (Indonesian style: 1.000.000)
  String _formatWithDots(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), 
      (Match match) => '${match[1]}.',
    );
  }

  // Get currency symbol only for current user
  Future<String> getCurrencySymbol() async {
    final currency = await getSelectedCurrency();
    return currency.symbol;
  }

  // Clear currency preference for current user
  Future<bool> clearUserCurrency() async {
    try {
      final currencyKey = await _getUserCurrencyKey();
      if (currencyKey == null) return false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(currencyKey);
      debugPrint('Cleared currency preference for current user');
      return true;
    } catch (e) {
      debugPrint('Error clearing user currency: $e');
      return false;
    }
  }

  // Clear currency preference for specific user (admin function)
  Future<bool> clearCurrencyForUser(String userId) async {
    try {
      final currencyKey = '$_currencyPrefix$userId';
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(currencyKey);
      debugPrint('Cleared currency preference for user: $userId');
      return true;
    } catch (e) {
      debugPrint('Error clearing currency for user $userId: $e');
      return false;
    }
  }

  // Utility method to migrate old currency to user-specific storage
  Future<bool> migrateOldCurrency() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return false;

      final prefs = await SharedPreferences.getInstance();
      const oldKey = 'selected_currency';
      final oldCurrencyJson = prefs.getString(oldKey);
      
      if (oldCurrencyJson == null) return true; // No old data to migrate
      
      final newCurrencyKey = '$_currencyPrefix${currentUser.id}';
      final hasNewData = prefs.getString(newCurrencyKey);
      
      // Only migrate if user doesn't have new format data yet
      if (hasNewData == null) {
        await prefs.setString(newCurrencyKey, oldCurrencyJson);
        debugPrint('Migrated old currency to user-specific storage');
      }
      
      // Remove old data after successful migration
      await prefs.remove(oldKey);
      return true;
    } catch (e) {
      debugPrint('Error migrating old currency: $e');
      return false;
    }
  }
}