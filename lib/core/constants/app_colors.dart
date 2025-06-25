import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  
  // Secondary Colors  
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);
  
  // Text Colors - Light Mode
  static const Color textLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textTertiaryLight = Color(0xFF9E9E9E);
  
  // Text Colors - Dark Mode
  static const Color textDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  static const Color textTertiaryDark = Color(0xFF9E9E9E);
  
  // Additional text colors yang dibutuhkan di themes
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  
  // Income/Expense Colors
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFF44336);
  static const Color incomeBackground = Color(0xFFE8F5E8);
  static const Color expenseBackground = Color(0xFFFFEBEE);
  
  // Error Colors
  static const Color error = Color(0xFFB00020);
  static const Color errorLight = Color(0xFFCF6679);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
  
  // Divider Colors
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
  
  // Icon Colors
  static const Color iconLight = Color(0xFF757575);
  static const Color iconDark = Color(0xFFBDBDBD);
  
  // Disabled Colors
  static const Color disabledLight = Color(0xFFE0E0E0);
  static const Color disabledDark = Color(0xFF616161);
  
  // Helper methods to get colors based on theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? textDark 
        : textLight;
  }
  
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? textSecondaryDark 
        : textSecondaryLight;
  }
  
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? borderDark 
        : borderLight;
  }
  
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? cardDark 
        : cardLight;
  }
  
  static Color getIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? iconDark 
        : iconLight;
  }
}