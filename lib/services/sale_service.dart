import 'package:dhandha/models/sale.dart';
import 'package:dhandha/models/sale_item.dart';
import 'package:dhandha/services/storage_service.dart';
import 'package:dhandha/services/customer_service.dart';
import 'package:dhandha/services/product_service.dart';
import 'package:dhandha/services/ledger_service.dart';
import 'package:dhandha/models/ledger_entry.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class SaleService {
  static const _uuid = Uuid();

  static Future<void> initializeSampleData() async {
    final existing = getAllSales();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final sampleSales = [
      Sale(
        id: _uuid.v4(), billNo: 'BILL-001', timestamp: now.subtract(const Duration(hours: 5)),
        totalAmount: 152, totalSavings: 8, paymentMode: PaymentMode.CASH,
        cashAmount: 152, status: SaleStatus.COMPLETED,
        createdAt: now, updatedAt: now,
      ),
      Sale(
        id: _uuid.v4(), billNo: 'BILL-002', timestamp: now.subtract(const Duration(hours: 4)),
        customerId: CustomerService.getAllCustomers().first.id,
        customerName: CustomerService.getAllCustomers().first.name,
        totalAmount: 460, totalSavings: 25, paymentMode: PaymentMode.UDHAAR,
        udhaarAmount: 460, status: SaleStatus.COMPLETED,
        createdAt: now, updatedAt: now,
      ),
      Sale(
        id: _uuid.v4(), billNo: 'BILL-003', timestamp: now.subtract(const Duration(hours: 2)),
        totalAmount: 295, totalSavings: 12, paymentMode: PaymentMode.UPI,
        upiAmount: 295, status: SaleStatus.COMPLETED,
        createdAt: now, updatedAt: now,
      ),
    ];

    for (var sale in sampleSales) {
      await saveSale(sale);
    }
  }

  static Future<String> generateBillNo() async {
    final billNum = await StorageService.getNextBillNumber();
    return 'BILL-${billNum.toString().padLeft(3, '0')}';
  }

  static Future<Sale> completeSale({
    required List<SaleItem> items,
    required PaymentMode paymentMode,
    String? customerId,
    String? customerName,
    double cashAmount = 0,
    double upiAmount = 0,
    double udhaarAmount = 0,
  }) async {
    final totalAmount = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final totalSavings = items.fold<double>(0, (sum, item) => sum + item.totalSavings);
    
    final billNo = await generateBillNo();
    final now = DateTime.now();
    
    final sale = Sale(
      id: _uuid.v4(),
      billNo: billNo,
      timestamp: now,
      customerId: customerId,
      customerName: customerName,
      totalAmount: totalAmount,
      totalSavings: totalSavings,
      paymentMode: paymentMode,
      cashAmount: cashAmount,
      upiAmount: upiAmount,
      udhaarAmount: udhaarAmount,
      status: SaleStatus.COMPLETED,
      createdAt: now,
      updatedAt: now,
    );

    await saveSale(sale);

    for (var item in items) {
      final saleItem = item.copyWith(saleId: sale.id);
      await saveSaleItem(saleItem);
      
      final product = ProductService.getProductById(item.productId);
      if (product != null) {
        await ProductService.updateStock(product.id, product.stockQty - item.qty);
      }
    }

    if (customerId != null && udhaarAmount > 0) {
      await CustomerService.updateOutstanding(customerId, udhaarAmount);
      await LedgerService.recordEntry(
        entityType: EntityType.CUSTOMER,
        entityId: customerId,
        entityName: customerName ?? '',
        type: LedgerEntryType.SALE,
        amount: udhaarAmount,
        notes: 'Bill: $billNo',
      );
    }

    return sale;
  }

  static Future<void> saveSale(Sale sale) async {
    await StorageService.saveToBox(StorageService.salesBox, sale.id, sale.toJson());
  }

  static Future<void> saveSaleItem(SaleItem item) async {
    await StorageService.saveToBox(StorageService.saleItemsBox, item.id, item.toJson());
  }

  static Sale? getSaleById(String id) {
    final data = StorageService.getFromBox(StorageService.salesBox, id);
    return data != null ? Sale.fromJson(data) : null;
  }

  static List<Sale> getAllSales() {
    final data = StorageService.getAllFromBox(StorageService.salesBox);
    return data.map((json) => Sale.fromJson(json)).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static List<SaleItem> getSaleItems(String saleId) {
    final data = StorageService.getAllFromBox(StorageService.saleItemsBox);
    return data.map((json) => SaleItem.fromJson(json))
        .where((item) => item.saleId == saleId).toList();
  }

  static List<Sale> getSalesForDate(DateTime date) {
    return getAllSales().where((sale) =>
      sale.timestamp.year == date.year &&
      sale.timestamp.month == date.month &&
      sale.timestamp.day == date.day
    ).toList();
  }

  static List<Sale> getSalesForDateRange(DateTime start, DateTime end) {
    return getAllSales().where((sale) =>
      sale.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
      sale.timestamp.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  static double getTodayRevenue() {
    final today = getSalesForDate(DateTime.now());
    return today.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
  }

  static double getTodayCash() {
    final today = getSalesForDate(DateTime.now());
    return today.fold<double>(0, (sum, sale) => sum + sale.cashAmount);
  }

  static double getTodayProfit() {
    final today = getSalesForDate(DateTime.now());
    double totalRevenue = 0;
    double totalCost = 0;

    for (var sale in today) {
      totalRevenue += sale.totalAmount;
      final items = getSaleItems(sale.id);
      for (var item in items) {
        final product = ProductService.getProductById(item.productId);
        if (product != null) {
          totalCost += product.costPrice * item.qty;
        }
      }
    }

    return totalRevenue - totalCost;
  }

  static Future<void> deleteSale(String id) async {
    await StorageService.deleteFromBox(StorageService.salesBox, id);
  }
}
