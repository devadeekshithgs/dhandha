import 'package:dhandha/models/vendor.dart';
import 'package:dhandha/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class VendorService {
  static const _uuid = Uuid();

  static Future<void> initializeSampleData() async {
    final existing = getAllVendors();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final sample = [
      Vendor(id: _uuid.v4(), name: 'Metro Cash & Carry', phone: '9012345678', gstin: '29ABCDE1234F1Z5', balancePayable: 0, createdAt: now, updatedAt: now),
      Vendor(id: _uuid.v4(), name: 'Hindustan Unilever Ltd.', phone: '9012345679', gstin: '27ABCDE1234F1Z6', balancePayable: 0, createdAt: now, updatedAt: now),
      Vendor(id: _uuid.v4(), name: 'ITC Foods', phone: '9012345680', gstin: '07ABCDE1234F1Z7', balancePayable: 0, createdAt: now, updatedAt: now),
    ];

    for (final v in sample) {
      await saveVendor(v);
    }
  }

  static Future<void> saveVendor(Vendor vendor) async {
    await StorageService.saveToBox(StorageService.vendorsBox, vendor.id, vendor.toJson());
  }

  static Vendor? getVendorById(String id) {
    final data = StorageService.getFromBox(StorageService.vendorsBox, id);
    return data != null ? Vendor.fromJson(data) : null;
  }

  static List<Vendor> getAllVendors() {
    final data = StorageService.getAllFromBox(StorageService.vendorsBox);
    return data.map((e) => Vendor.fromJson(e)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static List<Vendor> searchVendors(String query) {
    if (query.trim().isEmpty) return getAllVendors();
    final lower = query.toLowerCase();
    return getAllVendors().where((v) => v.name.toLowerCase().contains(lower) || v.phone.contains(query)).toList();
  }

  static Future<void> updateBalance(String vendorId, double delta) async {
    final v = getVendorById(vendorId);
    if (v == null) return;
    final updated = v.copyWith(balancePayable: v.balancePayable + delta, updatedAt: DateTime.now());
    await saveVendor(updated);
  }

  static Future<void> recordPayment(String vendorId, double amount) async {
    // Payment to vendor reduces payable
    final v = getVendorById(vendorId);
    if (v == null) return;
    final updated = v.copyWith(balancePayable: v.balancePayable - amount, updatedAt: DateTime.now());
    await saveVendor(updated);
  }

  static Future<void> deleteVendor(String id) async {
    await StorageService.deleteFromBox(StorageService.vendorsBox, id);
  }
}
