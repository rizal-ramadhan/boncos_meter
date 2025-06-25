import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/currency_provider.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;
  
  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () => _showDeleteDialog(context),
            icon: const Icon(Icons.delete_outline),
          ),
          IconButton(
            onPressed: () => _shareTransaction(context),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: Consumer2<TransactionProvider, CurrencyProvider>(
        builder: (context, provider, currencyProvider, child) {
          final transaction = provider.getTransactionById(transactionId);
          
          if (transaction == null) {
            return const Center(
              child: Text('Transaction not found'),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                _buildDetailItem(
                  context: context,
                  label: 'Title',
                  value: transaction.title,
                  isTitle: true,
                ),
                
                const SizedBox(height: 32),
                
                // Amount Section
                _buildDetailItem(
                  context: context,
                  label: 'Amount',
                  value: currencyProvider.formatAmount(transaction.amount),
                  isAmount: true,
                  isIncome: transaction.isIncome,
                ),
                
                const SizedBox(height: 32),
                
                // Transaction Type Section
                _buildDetailItem(
                  context: context,
                  label: 'Transaction type',
                  value: transaction.type,
                ),
                
                const SizedBox(height: 32),
                
                // Tag Section
                _buildDetailItem(
                  context: context,
                  label: 'Tag',
                  value: transaction.tag,
                ),
                
                const SizedBox(height: 32),
                
                // When Section
                _buildDetailItem(
                  context: context,
                  label: 'When',
                  value: _formatDateTime(transaction.date),
                ),
                
                const SizedBox(height: 32),
                
                // Note Section
                if (transaction.note.isNotEmpty)
                  _buildDetailItem(
                    context: context,
                    label: 'Note',
                    value: transaction.note,
                    isNote: true,
                  ),
                
                if (transaction.note.isNotEmpty)
                  const SizedBox(height: 32),
                
                // Created At Section
                _buildDetailItem(
                  context: context,
                  label: 'Created At',
                  value: _formatCreatedAt(transaction.createdAt),
                  isSecondary: true,
                ),
                
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editTransaction(context),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('EDIT'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required String label,
    required String value,
    bool isTitle = false,
    bool isAmount = false,
    bool isNote = false,
    bool isSecondary = false,
    bool isIncome = false,
  }) {
    final theme = Theme.of(context);
    
    // Label style
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: isSecondary 
          ? theme.textTheme.bodySmall?.color
          : theme.textTheme.bodyMedium?.color,
      fontWeight: FontWeight.w400,
    );
    
    // Value style
    TextStyle? valueStyle;
    if (isTitle) {
      valueStyle = theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      );
    } else if (isAmount) {
      valueStyle = theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: isIncome ? AppColors.income : AppColors.expense,
      );
    } else if (isNote) {
      valueStyle = theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.5,
      );
    } else {
      valueStyle = theme.textTheme.bodyLarge?.copyWith(
        fontWeight: isSecondary ? FontWeight.w400 : FontWeight.w500,
        color: isSecondary 
            ? theme.textTheme.bodyMedium?.color
            : theme.textTheme.bodyLarge?.color,
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: labelStyle,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: valueStyle,
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final dayFormatter = DateFormat('EEEE, dd MMM');
    final timeFormatter = DateFormat('h:mm a');
    return '${dayFormatter.format(dateTime)} ${timeFormatter.format(dateTime)}';
  }

  String _formatCreatedAt(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, yyyy, h:mm a');
    return formatter.format(dateTime);
  }

  void _editTransaction(BuildContext context) {
    context.push('${AppRouter.editTransaction}/$transactionId');
  }

  void _shareTransaction(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
    final transaction = provider.getTransactionById(transactionId);
    
    if (transaction != null) {
      final amount = currencyProvider.formatAmount(transaction.amount);
      final type = transaction.isIncome ? 'Income' : 'Expense';
      final date = DateFormat('MMM dd, yyyy').format(transaction.date);
      
      // Create shareable text
      final shareText = '''
🧾 BoncosMeter Transaction

📝 ${transaction.title}
💰 $amount ($type)
🏷️ ${transaction.tag}
📅 $date
${transaction.note.isNotEmpty ? '📄 ${transaction.note}' : ''}

Generated from BoncosMeter App
      '''.trim();
      
      // Copy to clipboard and show feedback
      Clipboard.setData(ClipboardData(text: shareText)).then((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Transaction details copied to clipboard'),
                ],
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  void _showDeleteDialog(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final transaction = provider.getTransactionById(transactionId);
    
    if (transaction == null) return;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: Text('Are you sure you want to delete "${transaction.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                
                if (!context.mounted) return;
                
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                
                final success = await provider.deleteTransaction(transaction.id);
                
                if (context.mounted) {
                  if (success) {
                    navigator.pop(); // Go back to previous screen
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Transaction deleted successfully'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
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