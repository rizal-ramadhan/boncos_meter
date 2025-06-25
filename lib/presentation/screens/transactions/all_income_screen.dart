import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/common_toolbar.dart';
import '../../widgets/transaction_list_item.dart';
import '../../providers/transaction_provider.dart';

class AllIncomeScreen extends StatelessWidget {
  const AllIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonToolbar(currentScreen: 'All Income'),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          // Use filteredTransactions instead of incomeTransactions
          final allFilteredTransactions = transactionProvider.filteredTransactions;
          final incomeTransactions = allFilteredTransactions
              .where((transaction) => transaction.isIncome)
              .toList();
          
          // Check if there's an active search
          final hasActiveSearch = transactionProvider.searchQuery.isNotEmpty;
          
          return Stack(
            children: [
              // Main content
              incomeTransactions.isEmpty
                  ? _EmptyIncomeState(hasActiveSearch: hasActiveSearch)
                  : Padding(
                      padding: EdgeInsets.only(
                        top: hasActiveSearch ? 72 : 0, // Add padding only when search is active
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: ListView.builder(
                        itemCount: incomeTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = incomeTransactions[index];
                          return TransactionListItem(transaction: transaction);
                        },
                      ),
                    ),
              
              // Search indicator overlay (positioned absolutely)
              if (hasActiveSearch)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Searching: "${transactionProvider.searchQuery}"',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            transactionProvider.clearSearch();
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRouter.addTransaction);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyIncomeState extends StatelessWidget {
  final bool hasActiveSearch;
  
  const _EmptyIncomeState({this.hasActiveSearch = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shadowColor = Colors.black.withValues(alpha: 0.05);
    final iconColor = AppColors.income.withValues(alpha: 0.7);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: hasActiveSearch 
                      ? Colors.orange.withValues(alpha: 0.1)
                      : AppColors.incomeBackground,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  hasActiveSearch ? Icons.search_off : Icons.south_west,
                  size: 48,
                  color: hasActiveSearch ? Colors.orange : iconColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                hasActiveSearch 
                    ? 'No income found'
                    : 'No income transactions yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                hasActiveSearch
                    ? 'Try adjusting your search terms or clear the search to see all income transactions'
                    : 'Start tracking your income by adding your first transaction',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (hasActiveSearch) {
                    // Clear search
                    Provider.of<TransactionProvider>(context, listen: false).clearSearch();
                  } else {
                    // Add transaction
                    context.push(AppRouter.addTransaction);
                  }
                },
                icon: Icon(hasActiveSearch ? Icons.clear : Icons.add),
                label: Text(hasActiveSearch ? 'Clear Search' : 'Add Income'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasActiveSearch ? Colors.orange : AppColors.income,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}