class Product {
  final String id;
  final String name;
  final String normalizedName;
  final String? barcode;
  final String? imagePath;
  final String category;
  final String? locationRack;
  final String? locationShelf;
  final double stockQty;
  final ProductUnit unit;
  final bool isLoose;
  final double mrp;
  final double sellingPrice;
  final double costPrice;
  final double lowStockThreshold;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.normalizedName,
    this.barcode,
    this.imagePath,
    required this.category,
    this.locationRack,
    this.locationShelf,
    required this.stockQty,
    required this.unit,
    required this.isLoose,
    required this.mrp,
    required this.sellingPrice,
    required this.costPrice,
    required this.lowStockThreshold,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  double get savings => mrp - sellingPrice;
  bool get isLowStock => stockQty <= lowStockThreshold;
  bool get isOutOfStock => stockQty <= 0;
  
  String get locationDisplay {
    if (locationRack != null && locationShelf != null) {
      return '$locationRack-$locationShelf';
    } else if (locationRack != null) {
      return locationRack!;
    }
    return '';
  }

  bool get isNearExpiry {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  Product copyWith({
    String? id,
    String? name,
    String? normalizedName,
    String? barcode,
    String? imagePath,
    String? category,
    String? locationRack,
    String? locationShelf,
    double? stockQty,
    ProductUnit? unit,
    bool? isLoose,
    double? mrp,
    double? sellingPrice,
    double? costPrice,
    double? lowStockThreshold,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    barcode: barcode ?? this.barcode,
    imagePath: imagePath ?? this.imagePath,
    category: category ?? this.category,
    locationRack: locationRack ?? this.locationRack,
    locationShelf: locationShelf ?? this.locationShelf,
    stockQty: stockQty ?? this.stockQty,
    unit: unit ?? this.unit,
    isLoose: isLoose ?? this.isLoose,
    mrp: mrp ?? this.mrp,
    sellingPrice: sellingPrice ?? this.sellingPrice,
    costPrice: costPrice ?? this.costPrice,
    lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    expiryDate: expiryDate ?? this.expiryDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'normalizedName': normalizedName,
    'barcode': barcode,
    'imagePath': imagePath,
    'category': category,
    'locationRack': locationRack,
    'locationShelf': locationShelf,
    'stockQty': stockQty,
    'unit': unit.name,
    'isLoose': isLoose,
    'mrp': mrp,
    'sellingPrice': sellingPrice,
    'costPrice': costPrice,
    'lowStockThreshold': lowStockThreshold,
    'expiryDate': expiryDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    normalizedName: json['normalizedName'],
    barcode: json['barcode'],
    imagePath: json['imagePath'],
    category: json['category'],
    locationRack: json['locationRack'],
    locationShelf: json['locationShelf'],
    stockQty: (json['stockQty'] as num).toDouble(),
    unit: ProductUnit.values.firstWhere((e) => e.name == json['unit']),
    isLoose: json['isLoose'],
    mrp: (json['mrp'] as num).toDouble(),
    sellingPrice: (json['sellingPrice'] as num).toDouble(),
    costPrice: (json['costPrice'] as num).toDouble(),
    lowStockThreshold: (json['lowStockThreshold'] as num).toDouble(),
    expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

enum ProductUnit {
  kg,
  gm,
  ltr,
  ml,
  pc;

  String get display {
    switch (this) {
      case ProductUnit.kg: return 'kg';
      case ProductUnit.gm: return 'gm';
      case ProductUnit.ltr: return 'ltr';
      case ProductUnit.ml: return 'ml';
      case ProductUnit.pc: return 'pc';
    }
  }
}
