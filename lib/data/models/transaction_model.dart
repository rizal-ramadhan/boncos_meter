class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; // 'Income' or 'Expense'
  final String tag;
  final DateTime date;
  final String note;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.tag,
    required this.date,
    required this.note,
    required this.createdAt,
  });

  // Copy with method for updates
  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? type,
    String? tag,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      tag: tag ?? this.tag,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'tag': tag,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      tag: json['tag'],
      date: DateTime.parse(json['date']),
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Check if transaction is income
  bool get isIncome => type == 'Income';

  // Check if transaction is expense  
  bool get isExpense => type == 'Expense';

  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amount: $amount, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}