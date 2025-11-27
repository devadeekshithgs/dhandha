class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String? receiptImagePath;
  final String? notes;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.receiptImagePath,
    this.notes,
    required this.createdAt,
  });

  Expense copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? date,
    String? receiptImagePath,
    String? notes,
    DateTime? createdAt,
  }) => Expense(
    id: id ?? this.id,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'amount': amount,
    'date': date.toIso8601String(),
    'receiptImagePath': receiptImagePath,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    category: json['category'],
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.parse(json['date']),
    receiptImagePath: json['receiptImagePath'],
    notes: json['notes'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
