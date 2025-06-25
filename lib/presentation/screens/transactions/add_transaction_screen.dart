import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? transactionId; // For edit mode
  
  const AddTransactionScreen({
    super.key,
    this.transactionId,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedType = 'Income';
  String _selectedTag = 'Food';
  DateTime _selectedDate = DateTime.now();
  
  final List<String> _transactionTypes = ['Income', 'Expense'];
  final List<String> _tags = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
    'Education',
    'Travel',
    'Other'
  ];

  TransactionModel? _existingTransaction;
  bool get _isEditMode => widget.transactionId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadExistingTransaction();
    }
  }

  void _loadExistingTransaction() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    _existingTransaction = provider.getTransactionById(widget.transactionId!);
    
    if (_existingTransaction != null) {
      _titleController.text = _existingTransaction!.title;
      _amountController.text = _existingTransaction!.amount.toString();
      _noteController.text = _existingTransaction!.note;
      _selectedType = _existingTransaction!.type;
      _selectedTag = _existingTransaction!.tag;
      _selectedDate = _existingTransaction!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Transaction' : 'Add Transaction'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: _isEditMode ? [
          IconButton(
            onPressed: () => _showDeleteDialog(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ] : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Amount Field
              _buildTextField(
                controller: _amountController,
                label: 'Amount',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Transaction Type Dropdown
              _buildDropdownField(
                label: 'Transaction type',
                value: _selectedType,
                items: _transactionTypes,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              // Tags Dropdown
              _buildDropdownField(
                label: 'Tags',
                value: _selectedTag,
                items: _tags,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedTag = newValue;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              // Date Picker Field
              _buildDateField(theme),
              
              const SizedBox(height: 24),
              
              // Note Field
              _buildTextField(
                controller: _noteController,
                label: 'Note',
                maxLines: 3,
              ),
              
              const SizedBox(height: 40),
              
              // Submit Button
              ElevatedButton(
                onPressed: _submitTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isEditMode ? 'UPDATE TRANSACTION' : 'ADD TRANSACTION',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark ? AppColors.textDark : AppColors.textLight,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          fontSize: 16,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.textSecondaryDark : Colors.grey[300]!,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.textSecondaryDark : Colors.grey[300]!,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return DropdownButtonFormField<String>(
      value: value,
      style: TextStyle(
        color: isDark ? AppColors.textDark : AppColors.textLight,
        fontSize: 16,
      ),
      dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          fontSize: 16,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.textSecondaryDark : Colors.grey[300]!,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.textSecondaryDark : Colors.grey[300]!,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildDateField(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.textSecondaryDark : Colors.grey[300]!,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'When',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: isDark ? AppColors.textSecondaryDark : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primary,
              surface: isDark ? AppColors.cardDark : AppColors.cardLight,
              onSurface: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitTransaction() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<TransactionProvider>();
      
      bool success;
      
      if (_isEditMode) {
        // Update existing transaction
        final updatedTransaction = _existingTransaction!.copyWith(
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text),
          type: _selectedType,
          tag: _selectedTag,
          date: _selectedDate,
          note: _noteController.text.trim(),
        );
        
        success = await provider.updateTransaction(updatedTransaction);
      } else {
        // Add new transaction
        success = await provider.addTransaction(
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text),
          type: _selectedType,
          tag: _selectedTag,
          date: _selectedDate,
          note: _noteController.text.trim(),
        );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditMode 
                  ? 'Transaction updated successfully!' 
                  : 'Transaction added successfully!'),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditMode 
                  ? 'Failed to update transaction. Please try again.' 
                  : 'Failed to add transaction. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showDeleteDialog(BuildContext context) {
    if (!_isEditMode || _existingTransaction == null) return;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: Text('Are you sure you want to delete "${_existingTransaction!.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                
                if (!mounted) return; // Check mounted before async operation
                
                // Cache context references before async operation
                final provider = Provider.of<TransactionProvider>(context, listen: false);
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                
                final success = await provider.deleteTransaction(_existingTransaction!.id);
                
                if (mounted) {
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