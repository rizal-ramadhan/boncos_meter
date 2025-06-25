import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/currency_provider.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final backgroundColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final shadowColor = Colors.black.withValues(alpha: 0.05);
    
    final iconBackgroundColor = transaction.isIncome 
        ? AppColors.incomeBackground 
        : AppColors.expenseBackground;
    
    final iconColor = transaction.isIncome 
        ? AppColors.income 
        : AppColors.expense;
    
    final amountColor = transaction.isIncome 
        ? AppColors.income 
        : AppColors.expense;

    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        final formattedAmount = currencyProvider.formatAmount(transaction.amount, decimalDigits: 0);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            elevation: 0,
            shadowColor: shadowColor,
            child: InkWell(
              onTap: onTap ?? () => _navigateToDetail(context),
              onLongPress: () => _showDeleteDialog(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        transaction.isIncome ? Icons.south_west : Icons.north_east,
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Transaction details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            transaction.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Tag and date
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: iconBackgroundColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  transaction.tag,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: iconColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 8),
                              
                              Text(
                                DateFormat('MMM dd').format(transaction.date),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${transaction.isIncome ? '+' : '-'}$formattedAmount',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        if (transaction.note.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Icon(
                            Icons.note_alt_outlined,
                            size: 14,
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context) {
    context.push('${AppRouter.transactionDetail}/${transaction.id}');
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: Text('Are you sure you want to delete "${transaction.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final provider = context.read<TransactionProvider>();
                final success = await provider.deleteTransaction(transaction.id);
                
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction deleted successfully'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete transaction'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}