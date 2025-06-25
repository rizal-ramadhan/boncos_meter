import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../../core/router/app_router.dart';
import 'screen_dropdown.dart';

class CommonToolbar extends StatelessWidget implements PreferredSizeWidget {
  final String currentScreen;
  
  const CommonToolbar({
    super.key,
    required this.currentScreen,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: ScreenDropdown(currentScreen: currentScreen),
      actions: [
        // Theme toggle button
        IconButton(
          onPressed: () {
            context.read<ThemeProvider>().toggleTheme();
          },
          icon: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Icon(
                themeProvider.isDarkMode 
                  ? Icons.lightbulb_outlined 
                  : Icons.lightbulb,
              );
            },
          ),
        ),
        // Search button (for Income and Expense screens)
        if (currentScreen != 'Dashboard')
          IconButton(
            onPressed: () => _showSearchDialog(context),
            icon: const Icon(Icons.search),
          ),
        // More options menu with profile
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                context.push(AppRouter.profile);
                break;
              case 'logout':
                _showLogoutDialog(context);
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outlined),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_outlined),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const SearchDialog(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                
                if (!context.mounted) return;
                
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final success = await authProvider.logout();
                
                if (context.mounted && success) {
                  // Navigate to login screen
                  context.go(AppRouter.login);
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Search Dialog Widget
class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  late TextEditingController _searchController;
  
  @override
  void initState() {
    super.initState();
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    _searchController = TextEditingController(text: transactionProvider.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // Force left-to-right direction
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.search),
            SizedBox(width: 8),
            Text('Search Transactions'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {
                  // Trigger rebuild to update clear button
                });
              },
              onSubmitted: (value) {
                _performSearch();
              },
              decoration: InputDecoration(
                hintText: 'Enter title, tag, or note...',
                hintTextDirection: TextDirection.ltr,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear search',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Search by transaction title, tag, or note content',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _clearSearch,
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _performSearch,
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    final searchQuery = _searchController.text.trim();
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    transactionProvider.searchTransactions(searchQuery);
    Navigator.of(context).pop();
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          searchQuery.isEmpty 
              ? 'Search cleared' 
              : 'Searching for "$searchQuery"',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _clearSearch() {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    transactionProvider.clearSearch();
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search cleared'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}