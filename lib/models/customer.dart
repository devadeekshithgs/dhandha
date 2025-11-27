class Customer {
  final String id;
  final String name;
  final String phone;
  final double creditLimit;
  final double currentOutstanding;
  final DateTime? lastPaymentDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.creditLimit,
    required this.currentOutstanding,
    this.lastPaymentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasOutstanding => currentOutstanding > 0;
  bool get isOverLimit => currentOutstanding > creditLimit;
  double get availableCredit => creditLimit - currentOutstanding;

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    double? creditLimit,
    double? currentOutstanding,
    DateTime? lastPaymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    creditLimit: creditLimit ?? this.creditLimit,
    currentOutstanding: currentOutstanding ?? this.currentOutstanding,
    lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'creditLimit': creditLimit,
    'currentOutstanding': currentOutstanding,
    'lastPaymentDate': lastPaymentDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    creditLimit: (json['creditLimit'] as num).toDouble(),
    currentOutstanding: (json['currentOutstanding'] as num).toDouble(),
    lastPaymentDate: json['lastPaymentDate'] != null ? DateTime.parse(json['lastPaymentDate']) : null,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}
