lib/services/storage_service.dartimport 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String productsBox = 'products';
  static const String customersBox = 'customers';
  static const String salesBox = 'sales';
  static const String saleItemsBox = 'saleItems';
  static const String ledgerBox = 'ledger';
  static const String vendorsBox = 'vendors';
  static const String expensesBox = 'expenses';
  static const String purchaseOrdersBox = 'purchaseOrders';
  static const String purchaseItemsBox = 'purchaseItems';
  static const String settingsKey = 'app_settings';
  static const String billCounterKey = 'bill_counter';
  static const String poCounterKey = 'po_counter';
  static const String _boxPrefix = 'box_';

  // In-memory cache of our emulated boxes. Persisted to SharedPreferences.
  static final Map<String, Map<String, String>> _boxes = {
    productsBox: <String, String>{},
    customersBox: <String, String>{},
    salesBox: <String, String>{},
    saleItemsBox: <String, String>{},
    ledgerBox: <String, String>{},
    vendorsBox: <String, String>{},
    expensesBox: <String, String>{},
    purchaseOrdersBox: <String, String>{},
    purchaseItemsBox: <String, String>{},
  };

  static Future<void> initialize() async {
    try {
      // Load all boxes from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      for (final boxName in _boxes.keys) {
        final key = '$_boxPrefix$boxName';
        final raw = prefs.getString(key);
        if (raw != null) {
          try {
            final decoded = jsonDecode(raw);
            if (decoded is Map) {
              _boxes[boxName] = decoded.map<String, String>((k, v) => MapEntry(k.toString(), v.toString()));
            }
          } catch (e) {
            debugPrint('⚠️ Skipping corrupted box "$boxName": $e');
          }
        }
      }
      debugPrint('✅ StorageService initialized (SharedPreferences-backed)');
    } catch (e) {
      debugPrint('❌ StorageService initialization error: $e');
    }
  }

  static Future<void> _persistBox(String boxName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_boxPrefix$boxName';
      await prefs.setString(key, jsonEncode(_boxes[boxName] ?? {}));
    } catch (e) {
      debugPrint('❌ Error persisting box $boxName: $e');
    }
  }

  static Future<void> saveToBox(String boxName, String key, Map<String, dynamic> data) async {
    try {
      final map = _boxes[boxName] ?? <String, String>{};
      map[key] = jsonEncode(data);
      _boxes[boxName] = map;
      await _persistBox(boxName);
    } catch (e) {
      debugPrint('❌ Error saving to $boxName: $e');
    }
  }

  static Map<String, dynamic>? getFromBox(String boxName, String key) {
    try {
      final map = _boxes[boxName];
      final data = map?[key];
      if (data == null) return null;
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error reading from $boxName: $e');
      return null;
    }
  }

  static List<Map<String, dynamic>> getAllFromBox(String boxName) {
    try {
      final map = _boxes[boxName] ?? {};
      final List<Map<String, dynamic>> result = [];
      for (final value in map.values) {
        try {
          final data = jsonDecode(value);
          if (data is Map<String, dynamic>) {
            result.add(data);
          }
        } catch (e) {
          debugPrint('⚠️ Skipping corrupted entry in $boxName: $e');
          continue;
        }
      }
      return result;
    } catch (e) {
      debugPrint('❌ Error reading all from $boxName: $e');
      return [];
    }
  }

  static Future<void> deleteFromBox(String boxName, String key) async {
    try {
      final map = _boxes[boxName];
      map?.remove(key);
      await _persistBox(boxName);
    } catch (e) {
      debugPrint('❌ Error deleting from $boxName: $e');
    }
  }

  static Future<void> clearBox(String boxName) async {
    try {
      _boxes[boxName] = <String, String>{};
      await _persistBox(boxName);
    } catch (e) {
      debugPrint('❌ Error clearing $boxName: $e');
    }
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(settingsKey, jsonEncode(settings));
    } catch (e) {
      debugPrint('❌ Error saving settings: $e');
    }
  }

  static Future<Map<String, dynamic>?> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(settingsKey);
      if (data == null) return null;
      return jsonDecode(data);
    } catch (e) {
      debugPrint('❌ Error reading settings: $e');
      return null;
    }
  }

  static Future<int> getNextBillNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(billCounterKey) ?? 0;
      final next = current + 1;
      await prefs.setInt(billCounterKey, next);
      return next;
    } catch (e) {
      debugPrint('❌ Error getting bill number: $e');
      return 1;
    }
  }

  static Future<int> getNextPONumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(poCounterKey) ?? 0;
      final next = current + 1;
      await prefs.setInt(poCounterKey, next);
      return next;
    } catch (e) {
      debugPrint('❌ Error getting PO number: $e');
      return 1;
    }
  }

  static Future<Map<String, dynamic>> generateBackupJson() async {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'products': getAllFromBox(productsBox),
      'customers': getAllFromBox(customersBox),
      'sales': getAllFromBox(salesBox),
      'saleItems': getAllFromBox(saleItemsBox),
      'ledger': getAllFromBox(ledgerBox),
      'vendors': getAllFromBox(vendorsBox),
      'expenses': getAllFromBox(expensesBox),
      'purchaseOrders': getAllFromBox(purchaseOrdersBox),
      'purchaseItems': getAllFromBox(purchaseItemsBox),
      'settings': await getSettings(),
    };
  }

  static Future<void> restoreFromBackup(Map<String, dynamic> backup) async {
    try {
      await clearBox(productsBox);
      await clearBox(customersBox);
      await clearBox(salesBox);
      await clearBox(saleItemsBox);
      await clearBox(ledgerBox);
      await clearBox(vendorsBox);
      await clearBox(expensesBox);
      await clearBox(purchaseOrdersBox);
      await clearBox(purchaseItemsBox);

      for (var item in backup['products'] ?? []) {
        await saveToBox(productsBox, item['id'], item);
      }
      for (var item in backup['customers'] ?? []) {
        await saveToBox(customersBox, item['id'], item);
      }
      for (var item in backup['sales'] ?? []) {
        await saveToBox(salesBox, item['id'], item);
      }
      for (var item in backup['saleItems'] ?? []) {
        await saveToBox(saleItemsBox, item['id'], item);
      }
      for (var item in backup['ledger'] ?? []) {
        await saveToBox(ledgerBox, item['id'], item);
      }
      for (var item in backup['vendors'] ?? []) {
        await saveToBox(vendorsBox, item['id'], item);
      }
      for (var item in backup['expenses'] ?? []) {
        await saveToBox(expensesBox, item['id'], item);
      }
      for (var item in backup['purchaseOrders'] ?? []) {
        await saveToBox(purchaseOrdersBox, item['id'], item);
      }
      for (var item in backup['purchaseItems'] ?? []) {
        await saveToBox(purchaseItemsBox, item['id'], item);
      }

      if (backup['settings'] != null) {
        await saveSettings(backup['settings']);
      }

      debugPrint('✅ Backup restored successfully');
    } catch (e) {
      debugPrint('❌ Error restoring backup: $e');
    }
  }
}
