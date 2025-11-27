import 'package:dhandha/models/product.dart';
import 'package:dhandha/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class ProductService {
  static const _uuid = Uuid();

  static Future<void> initializeSampleData() async {
    final existing = getAllProducts();
    if (existing.isNotEmpty) return;

    final sampleProducts = [
      Product(
        id: _uuid.v4(), name: 'Maggi Noodles', normalizedName: _normalize('Maggi Noodles'),
        barcode: '8901058847536', category: 'Instant Food', locationRack: 'A', locationShelf: '1',
        stockQty: 48, unit: ProductUnit.pc, isLoose: false, mrp: 14, sellingPrice: 12, costPrice: 10,
        lowStockThreshold: 10, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(), name: 'Tata Salt', normalizedName: _normalize('Tata Salt'),
        barcode: '8901058842517', category: 'Grocery', locationRack: 'B', locationShelf: '2',
        stockQty: 25, unit: ProductUnit.kg, isLoose: false, mrp: 25, sellingPrice: 23, costPrice: 20,
        lowStockThreshold: 5, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(), name: 'Britannia Good Day', normalizedName: _normalize('Britannia Good Day'),
        barcode: '8901063001138', category: 'Biscuits', locationRack: 'A', locationShelf: '3',
        stockQty: 60, unit: ProductUnit.pc, isLoose: false, mrp: 30, sellingPrice: 28, costPrice: 24,
        lowStockThreshold: 15, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(), name: 'Parle G', normalizedName: _normalize('Parle G'),
        barcode: '8901719104107', category: 'Biscuits', locationRack: 'A', locationShelf: '3',
        stockQty: 8, unit: ProductUnit.pc, isLoose: false, mrp: 10, sellingPrice: 10, costPrice: 8,
        lowStockThreshold: 10, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(), name: 'Amul Milk', normalizedName: _normalize('Amul Milk'),
        category: 'Dairy', locationRack: 'C', locationShelf: '1',
        stockQty: 20, unit: ProductUnit.ltr, isLoose: false, mrp: 60, sellingPrice: 60, costPrice: 55,
        lowStockThreshold: 5, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(), name: 'Fortune Sunflower Oil', normalizedName: _normalize('Fortune Sunflower Oil'),
        category: 'Cooking', locationRack: 'D', locationShelf: '1',
        stockQty: 12, unit: ProductUnit.ltr, isLoose: false, mrp: 200, sellingPrice: 185, costPrice: 170,
        lowStockThreshold: 3, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(), name: 'Vim Dishwash Bar', normalizedName: _normalize('Vim Dishwash Bar'),
        category: 'Cleaning', locationRack: 'E', locationShelf: '2',
        stockQty: 35, unit: ProductUnit.pc, isLoose: false, mrp: 15, sellingPrice: 14, costPrice: 12,
        lowStockThreshold: 10, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(), name: 'Colgate Toothpaste', normalizedName: _normalize('Colgate Toothpaste'),
        category: 'Personal Care', locationRack: 'E', locationShelf: '3',
        stockQty: 22, unit: ProductUnit.pc, isLoose: false, mrp: 80, sellingPrice: 75, costPrice: 65,
        lowStockThreshold: 8, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(), name: 'Red Label Tea', normalizedName: _normalize('Red Label Tea'),
        category: 'Beverages', locationRack: 'B', locationShelf: '1',
        stockQty: 18, unit: ProductUnit.gm, isLoose: false, mrp: 150, sellingPrice: 145, costPrice: 130,
        lowStockThreshold: 5, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(), name: 'India Gate Basmati Rice', normalizedName: _normalize('India Gate Basmati Rice'),
        category: 'Grocery', locationRack: 'B', locationShelf: '4',
        stockQty: 10, unit: ProductUnit.kg, isLoose: true, mrp: 180, sellingPrice: 170, costPrice: 155,
        lowStockThreshold: 3, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(), name: 'Rin Detergent', normalizedName: _normalize('Rin Detergent'),
        category: 'Cleaning', locationRack: 'E', locationShelf: '1',
        stockQty: 3, unit: ProductUnit.kg, isLoose: false, mrp: 120, sellingPrice: 115, costPrice: 100,
        lowStockThreshold: 5, expiryDate: DateTime.now().add(const Duration(days: 20)),
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
      Product(
        id: _uuid.v4(), name: 'Thums Up', normalizedName: _normalize('Thums Up'),
        category: 'Beverages', locationRack: 'C', locationShelf: '3',
        stockQty: 2, unit: ProductUnit.ltr, isLoose: false, mrp: 40, sellingPrice: 40, costPrice: 35,
        lowStockThreshold: 6, expiryDate: DateTime.now().add(const Duration(days: 15)),
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
    ];

    for (var product in sampleProducts) {
      await saveProduct(product);
    }
  }

  static String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[aeiou]'), '').replaceAll(RegExp(r'(.)\1+'), r'\1');
  }

  static List<Product> smartSearch(String query) {
    if (query.trim().isEmpty) return [];
    
    final allProducts = getAllProducts();
    final normalized = _normalize(query);
    final results = <Product>[];

    if (RegExp(r'^\d+$').hasMatch(query)) {
      final barcodeMatch = allProducts.where((p) => p.barcode == query);
      if (barcodeMatch.isNotEmpty) return barcodeMatch.toList();
    }

    for (var product in allProducts) {
      if (product.normalizedName.contains(normalized) || product.name.toLowerCase().contains(query.toLowerCase())) {
        results.add(product);
      }
    }

    results.sort((a, b) => a.stockQty > 0 ? -1 : 1);
    return results;
  }

  static Future<void> saveProduct(Product product) async {
    await StorageService.saveToBox(StorageService.productsBox, product.id, product.toJson());
  }

  static Product? getProductById(String id) {
    final data = StorageService.getFromBox(StorageService.productsBox, id);
    return data != null ? Product.fromJson(data) : null;
  }

  static List<Product> getAllProducts() {
    final data = StorageService.getAllFromBox(StorageService.productsBox);
    return data.map((json) => Product.fromJson(json)).toList();
  }

  static List<Product> getLowStockProducts() {
    return getAllProducts().where((p) => p.isLowStock).toList();
  }

  static List<Product> getNearExpiryProducts() {
    return getAllProducts().where((p) => p.isNearExpiry).toList();
  }

  static Future<void> updateStock(String productId, double newQty) async {
    final product = getProductById(productId);
    if (product == null) return;
    final updated = product.copyWith(stockQty: newQty, updatedAt: DateTime.now());
    await saveProduct(updated);
  }

  static Future<void> deleteProduct(String id) async {
    await StorageService.deleteFromBox(StorageService.productsBox, id);
  }
}
