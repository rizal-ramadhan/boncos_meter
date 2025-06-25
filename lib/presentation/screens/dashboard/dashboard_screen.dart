import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/summary_cards.dart';
import '../../widgets/recent_transactions.dart';
import '../../widgets/common_toolbar.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/currency_provider.dart';
import '../../../core/router/app_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load transactions and initialize currency when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
        final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
        
        transactionProvider.loadTransactions();
        currencyProvider.initializeCurrency();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonToolbar(currentScreen: 'Dashboard'),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Balance Section
            BalanceCard(),
            
            SizedBox(height: 24),
            
            // Income & Expense Summary Cards
            SummaryCards(),
            
            SizedBox(height: 32),
            
            // Recent Transactions
            RecentTransactions(),
          ],
        ),
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