import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_themes.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/currency_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BoncosMeterApp());
}

class BoncosMeterApp extends StatelessWidget {
  const BoncosMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TransactionProvider>(
          create: (context) => TransactionProvider(),
          update: (context, authProvider, transactionProvider) {
            // Set up the connection between providers
            transactionProvider?.setAuthProvider(authProvider);
            return transactionProvider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, CurrencyProvider>(
          create: (context) => CurrencyProvider(),
          update: (context, authProvider, currencyProvider) {
            // Set up the connection between providers
            currencyProvider?.setAuthProvider(authProvider);
            return currencyProvider!;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp.router(
                title: 'BoncosMeter',
                debugShowCheckedModeBanner: false,
                theme: AppThemes.lightTheme,
                darkTheme: AppThemes.darkTheme,
                themeMode: themeProvider.themeMode,
                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}