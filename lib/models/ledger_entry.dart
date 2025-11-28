class LedgerEntry {
  final String id;
  final EntityType entityType;
  final String entityId;
  final String entityName;
  final LedgerEntryType type;
  final double amount;
  final double balanceAfter;
  final DateTime timestamp;
  final String? notes;
  final DateTime createdAt;

  LedgerEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.entityName,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.timestamp,
    this.notes,
    required this.createdAt,
  });

  LedgerEntry copyWith({
    String? id,
    EntityType? entityType,
    String? entityId,
    String? entityName,
    LedgerEntryType? type,
    double? amount,
    double? balanceAfter,
    DateTime? timestamp,
    String? notes,
    DateTime? createdAt,
  }) => LedgerEntry(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    entityName: entityName ?? this.entityName,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    balanceAfter: balanceAfter ?? this.balanceAfter,
    timestamp: timestamp ?? this.timestamp,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'entityType': entityType.name,
    'entityId': entityId,
    'entityName': entityName,
    'type': type.name,
    'amount': amount,
    'balanceAfter': balanceAfter,
    'timestamp': timestamp.toIso8601String(),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory LedgerEntry.fromJson(Map<String, dynamic> json) => LedgerEntry(
    id: json['id'],
    entityType: EntityType.values.firstWhere((e) => e.name == json['entityType']),
    entityId: json['entityId'],
    entityName: json['entityName'],
    type: LedgerEntryType.values.firstWhere((e) => e.name == json['type']),
    amount: (json['amount'] as num).toDouble(),
    balanceAfter: (json['balanceAfter'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp']),
    notes: json['notes'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

enum EntityType { CUSTOMER, VENDOR }
enum LedgerEntryType { SALE, PAYMENT, DEPOSIT, PURCHASE }
