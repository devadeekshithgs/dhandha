import 'package:dhandha/models/purchase_order.dart';
import 'package:dhandha/models/purchase_item.dart';
import 'package:dhandha/services/storage_service.dart';
import 'package:dhandha/services/product_service.dart';
import 'package:dhandha/services/vendor_service.dart';
import 'package:dhandha/services/ledger_service.dart';
import 'package:dhandha/models/ledger_entry.dart';
import 'package:uuid/uuid.dart';

class PurchaseService {
  static const _uuid = Uuid();

  static Future<String> generatePONumber() async {
    final num = await StorageService.getNextPONumber();
    return 'PO-${num.toString().padLeft(3, '0')}';
  }

  static Future<void> saveOrder(PurchaseOrder order) async {
    await StorageService.saveToBox(StorageService.purchaseOrdersBox, order.id, order.toJson());
  }

  static Future<void> saveItem(PurchaseItem item) async {
    await StorageService.saveToBox(StorageService.purchaseItemsBox, item.id, item.toJson());
  }

  static PurchaseOrder? getOrderById(String id) {
    final data = StorageService.getFromBox(StorageService.purchaseOrdersBox, id);
    return data != null ? PurchaseOrder.fromJson(data) : null;
  }

  static List<PurchaseOrder> getAllOrders() {
    final data = StorageService.getAllFromBox(StorageService.purchaseOrdersBox);
    return data.map((e) => PurchaseOrder.fromJson(e)).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static List<PurchaseItem> getItemsForOrder(String purchaseId) {
    final data = StorageService.getAllFromBox(StorageService.purchaseItemsBox);
    return data.map((e) => PurchaseItem.fromJson(e)).where((i) => i.purchaseId == purchaseId).toList();
  }

  static Future<PurchaseOrder> createOrder({
    required String vendorId,
    required String vendorName,
    required List<PurchaseItem> items,
    String? invoiceNo,
    DateTime? expectedDate,
    double tax = 0,
    double shipping = 0,
    double cashAmount = 0,
    double upiAmount = 0,
    double creditAmount = 0,
    String? notes,
    bool receiveNow = false,
  }) async {
    final subtotal = items.fold<double>(0, (sum, i) => sum + i.totalCost);
    final total = subtotal + tax + shipping;

    final poNumber = await generatePONumber();
    final now = DateTime.now();
    final status = receiveNow ? PurchaseStatus.RECEIVED : PurchaseStatus.ORDERED;

    final order = PurchaseOrder(
      id: _uuid.v4(),
      poNumber: poNumber,
      timestamp: now,
      vendorId: vendorId,
      vendorName: vendorName,
      status: status,
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      totalCost: total,
      invoiceNo: invoiceNo,
      expectedDate: expectedDate,
      receivedDate: receiveNow ? now : null,
      cashAmount: cashAmount,
      upiAmount: upiAmount,
      creditAmount: creditAmount,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    await saveOrder(order);
    for (final item in items) {
      await saveItem(item.copyWith(purchaseId: order.id));
    }

    if (receiveNow) {
      await _applyReceiptEffects(order);
    }

    return order;
  }

  static Future<void> markAsReceived(String orderId) async {
    final existing = getOrderById(orderId);
    if (existing == null) return;
    if (existing.status == PurchaseStatus.RECEIVED) return;

    final updated = existing.copyWith(
      status: PurchaseStatus.RECEIVED,
      receivedDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await saveOrder(updated);
    await _applyReceiptEffects(updated);
  }

  static Future<void> _applyReceiptEffects(PurchaseOrder order) async {
    // Increase stock
    final items = getItemsForOrder(order.id);
    for (final item in items) {
      final product = ProductService.getProductById(item.productId);
      if (product != null) {
        await ProductService.updateStock(product.id, product.stockQty + item.qty);
      }
    }

    // Update vendor payable (credit)
    if (order.creditAmount > 0) {
      await VendorService.updateBalance(order.vendorId, order.creditAmount);
      await LedgerService.recordEntry(
        entityType: EntityType.VENDOR,
        entityId: order.vendorId,
        entityName: order.vendorName,
        type: LedgerEntryType.PURCHASE,
        amount: order.creditAmount,
        notes: 'PO: ${order.poNumber}',
      );
    }
  }

  static Future<void> deleteOrder(String id) async {
    await StorageService.deleteFromBox(StorageService.purchaseOrdersBox, id);
  }
}
