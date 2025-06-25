import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/auth_wrapper.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/transactions/all_income_screen.dart';
import '../../presentation/screens/transactions/all_expense_screen.dart';
import '../../presentation/screens/transactions/add_transaction_screen.dart';
import '../../presentation/screens/transactions/transaction_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile/change_password_screen.dart';
import '../../presentation/screens/profile/delete_account_screen.dart'; // Only import from delete_account_screen.dart
import '../../presentation/screens/settings/currency_screen.dart';

class AppRouter {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  
  // App routes
  static const String dashboard = '/dashboard';
  static const String allIncome = '/income';
  static const String allExpense = '/expense';
  static const String addTransaction = '/add-transaction';
  static const String editTransaction = '/edit-transaction';
  static const String transactionDetail = '/transaction-detail';
  
  // Profile routes
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String deleteAccount = '/delete-account';
  
  // Settings routes
  static const String currency = '/currency';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Auth Wrapper (decides login vs dashboard)
      GoRoute(
        path: splash,
        builder: (context, state) => const AuthWrapper(),
      ),
      
      // Auth routes
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Protected app routes
      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: allIncome,
        builder: (context, state) => const AllIncomeScreen(),
      ),
      GoRoute(
        path: allExpense,
        builder: (context, state) => const AllExpenseScreen(),
      ),
      GoRoute(
        path: addTransaction,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '$editTransaction/:id',
        builder: (context, state) {
          final transactionId = state.pathParameters['id']!;
          return AddTransactionScreen(transactionId: transactionId);
        },
      ),
      GoRoute(
        path: '$transactionDetail/:id',
        builder: (context, state) {
          final transactionId = state.pathParameters['id']!;
          return TransactionDetailScreen(transactionId: transactionId);
        },
      ),
      
      // Profile routes - ALL PROFILE FEATURES
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: deleteAccount,
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      
      // Settings routes
      GoRoute(
        path: currency,
        builder: (context, state) => const CurrencyScreen(),
      ),
    ],
  );
}