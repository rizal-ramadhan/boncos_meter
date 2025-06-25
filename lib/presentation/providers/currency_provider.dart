import 'package:flutter/foundation.dart';
import '../../data/models/currency_model.dart';
import '../../data/services/currency_service.dart';
import 'auth_provider.dart';

class CurrencyProvider extends ChangeNotifier {
  final CurrencyService _currencyService = CurrencyService();
  
  CurrencyModel? _selectedCurrency;
  bool _isLoading = false;
  AuthProvider? _authProvider;

  // Getters
  CurrencyModel? get selectedCurrency => _selectedCurrency;
  bool get isLoading => _isLoading;
  
  List<CurrencyModel> get supportedCurrencies => 
      _currencyService.getSupportedCurrencies();

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
      // User logged in or switched - reload currency
      debugPrint('User changed - reloading currency preferences');
      initializeCurrency();
    } else {
      // User logged out - reset to default
      debugPrint('User logged out - resetting currency to default');
      _selectedCurrency = CurrencyModel.getCurrencyByCode('IDR') ?? 
                         CurrencyModel.supportedCurrencies.first;
      notifyListeners();
    }
  }

  // Initialize currency for current user
  Future<void> initializeCurrency() async {
    _setLoading(true);
    try {
      _selectedCurrency = await _currencyService.getSelectedCurrency();
      debugPrint('Initialized currency for current user: ${_selectedCurrency?.code}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing currency: $e');
      // Fallback to default currency
      _selectedCurrency = CurrencyModel.getCurrencyByCode('IDR') ?? 
                         CurrencyModel.supportedCurrencies.first;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Update selected currency for current user
  Future<bool> updateCurrency(CurrencyModel currency) async {
    // Check if user is logged in
    if (_authProvider?.isLoggedIn != true) {
      debugPrint('Cannot update currency: No user logged in');
      // Still update locally for immediate UI feedback
      _selectedCurrency = currency;
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final success = await _currencyService.setSelectedCurrency(currency);
      if (success) {
        _selectedCurrency = currency;
        debugPrint('Updated currency for current user: ${currency.code}');
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error updating currency: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Format amount with current currency using proper formatting
  String formatAmount(double amount, {int decimalDigits = 2}) {
    if (_selectedCurrency == null) {
      // Fallback formatting if no currency selected
      if (decimalDigits == 0) {
        return 'Rp ${_formatWithDots(amount.round())}';
      } else {
        return 'Rp ${_formatWithDots(amount.round())}';
      }
    }
    
    // Handle special formatting for specific currencies
    switch (_selectedCurrency!.code) {
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
        return '${_selectedCurrency!.symbol}${_formatWithCommas(amount.round())}';
        
      case 'EUR':
        // Euro: €1,000.00
        if (decimalDigits == 0) {
          return '€${_formatWithCommas(amount.round())}';
        } else {
          return '€${_formatWithCommas(amount)}';
        }
        
      case 'INR':
        // Indian Rupee: ₹1,00,000 (simplified to standard format)
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
          return '${_selectedCurrency!.symbol}${_formatWithCommas(amount.round())}';
        } else {
          return '${_selectedCurrency!.symbol}${_formatWithCommas(amount)}';
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

  // Get currency symbol
  String get currencySymbol {
    return _selectedCurrency?.symbol ?? 'Rp';
  }

  // Get currency code
  String get currencyCode {
    return _selectedCurrency?.code ?? 'IDR';
  }

  // Get currency name
  String get currencyName {
    return _selectedCurrency?.name ?? 'Indonesian Rupiah';
  }

  // Check if currency is selected
  bool isCurrencySelected(CurrencyModel currency) {
    return _selectedCurrency?.code == currency.code;
  }

  // Reset to default currency
  Future<void> resetToDefault() async {
    final defaultCurrency = CurrencyModel.getCurrencyByCode('IDR') ?? 
                           CurrencyModel.supportedCurrencies.first;
    await updateCurrency(defaultCurrency);
  }

  // Refresh currency data
  Future<void> refreshCurrency() async {
    debugPrint('Refreshing currency data');
    await initializeCurrency();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear currency for current user (for logout)
  Future<void> clearCurrency() async {
    try {
      await _currencyService.clearUserCurrency();
      _selectedCurrency = CurrencyModel.getCurrencyByCode('IDR') ?? 
                         CurrencyModel.supportedCurrencies.first;
      debugPrint('Cleared currency for current user');
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing currency: $e');
    }
  }
}