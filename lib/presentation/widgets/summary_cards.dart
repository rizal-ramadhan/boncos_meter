import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/transaction_provider.dart';
import '../providers/currency_provider.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, CurrencyProvider>(
      builder: (context, transactionProvider, currencyProvider, child) {
        final totalIncome = transactionProvider.totalIncome;
        final totalExpense = transactionProvider.totalExpense;
        
        final formattedIncome = currencyProvider.formatAmount(totalIncome, decimalDigits: 0);
        final formattedExpense = currencyProvider.formatAmount(totalExpense, decimalDigits: 0);

        return Row(
          children: [
            // Income Card
            Expanded(
              child: _SummaryCard(
                title: 'TOTAL INCOME',
                amount: formattedIncome,
                isIncome: true,
                icon: Icons.south_west,
              ),
            ),
            const SizedBox(width: 16),
            // Expense Card
            Expanded(
              child: _SummaryCard(
                title: 'TOTAL EXPENSE',
                amount: formattedExpense,
                isIncome: false,
                icon: Icons.north_east,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final bool isIncome;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final backgroundColor = isDark 
        ? AppColors.cardDark 
        : AppColors.cardLight;
    
    final iconBackgroundColor = isIncome 
        ? AppColors.incomeBackground 
        : AppColors.expenseBackground;
    
    final iconColor = isIncome 
        ? AppColors.income 
        : AppColors.expense;
    
    final amountColor = isIncome 
        ? AppColors.income 
        : AppColors.expense;

    final shadowColor = Colors.black.withValues(alpha: 0.05);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Amount
          Text(
            '${isIncome ? '+' : '-'}$amount',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}