import 'package:dhandha/models/ledger_entry.dart';
import 'package:dhandha/services/storage_service.dart';
import 'package:dhandha/services/customer_service.dart';
import 'package:dhandha/services/vendor_service.dart';
import 'package:uuid/uuid.dart';

class LedgerService {
  static const _uuid = Uuid();

  static Future<void> recordEntry({
    required EntityType entityType,
    required String entityId,
    required String entityName,
    required LedgerEntryType type,
    required double amount,
    String? notes,
  }) async {
    double currentBalance = 0;
    
    if (entityType == EntityType.CUSTOMER) {
      final customer = CustomerService.getCustomerById(entityId);
      currentBalance = customer?.currentOutstanding ?? 0;
    } else if (entityType == EntityType.VENDOR) {
      final vendor = VendorService.getVendorById(entityId);
      currentBalance = vendor?.balancePayable ?? 0;
    }

    final entry = LedgerEntry(
      id: _uuid.v4(),
      entityType: entityType,
      entityId: entityId,
      entityName: entityName,
      type: type,
      amount: amount,
      balanceAfter: currentBalance,
      timestamp: DateTime.now(),
      notes: notes,
      createdAt: DateTime.now(),
    );

    await saveLedgerEntry(entry);
  }

  static Future<void> saveLedgerEntry(LedgerEntry entry) async {
    await StorageService.saveToBox(StorageService.ledgerBox, entry.id, entry.toJson());
  }

  static List<LedgerEntry> getAllEntries() {
    final data = StorageService.getAllFromBox(StorageService.ledgerBox);
    return data.map((json) => LedgerEntry.fromJson(json)).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static List<LedgerEntry> getEntriesForEntity(String entityId) {
    return getAllEntries().where((e) => e.entityId == entityId).toList();
  }

  static Future<void> deleteEntry(String id) async {
    await StorageService.deleteFromBox(StorageService.ledgerBox, id);
  }
}
