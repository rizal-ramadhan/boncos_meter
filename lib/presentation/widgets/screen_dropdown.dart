import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

class ScreenDropdown extends StatelessWidget {
  final String currentScreen;
  
  const ScreenDropdown({
    super.key,
    required this.currentScreen,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: currentScreen,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          size: 20,
        ),
        style: Theme.of(context).textTheme.headlineMedium,
        dropdownColor: Theme.of(context).scaffoldBackgroundColor,
        items: const [
          DropdownMenuItem(
            value: 'Dashboard',
            child: Text('Dashboard'),
          ),
          DropdownMenuItem(
            value: 'All Income',
            child: Text('All Income'),
          ),
          DropdownMenuItem(
            value: 'All Expense',
            child: Text('All Expense'),
          ),
        ],
        onChanged: (String? newValue) {
          if (newValue != null && newValue != currentScreen) {
            _navigateToScreen(context, newValue);
          }
        },
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String screenName) {
    switch (screenName) {
      case 'Dashboard':
        context.go(AppRouter.dashboard);
        break;
      case 'All Income':
        context.go(AppRouter.allIncome);
        break;
      case 'All Expense':
        context.go(AppRouter.allExpense);
        break;
    }
  }
}