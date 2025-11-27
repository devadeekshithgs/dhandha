import 'package:dhandha/models/settings.dart';
import 'package:dhandha/services/storage_service.dart';

class SettingsService {
  static Future<void> initializeDefaultSettings() async {
    final existing = await getSettings();
    if (existing != null) return;

    final defaultSettings = Settings(
      shopName: 'My Kirana Store',
      ownerName: 'Store Owner',
      ownerPhone: '9876543210',
      upiId: 'shopkeeper@paytm',
      autoBackupEnabled: true,
    );

    await saveSettings(defaultSettings);
  }

  static Future<void> saveSettings(Settings settings) async {
    await StorageService.saveSettings(settings.toJson());
  }

  static Future<Settings?> getSettings() async {
    final data = await StorageService.getSettings();
    return data != null ? Settings.fromJson(data) : null;
  }

  static Future<void> updateBackupTime() async {
    final settings = await getSettings();
    if (settings == null) return;
    
    final updated = settings.copyWith(lastBackupTime: DateTime.now());
    await saveSettings(updated);
  }
}
