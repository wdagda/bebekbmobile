import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  Future<void> showLowStockAlert(String namaKandang, double stokKg) async {
    await _show(
      id: 1,
      title: '⚠️ Stok Pakan Hampir Habis!',
      body: 'Kandang $namaKandang tersisa ${stokKg.toStringAsFixed(1)} kg',
    );
  }

  Future<void> showProductionDropAlert(String kandang) async {
    await _show(
      id: 2,
      title: '📉 Produksi Menurun',
      body: 'Produksi telur di $kandang lebih rendah dari rata-rata',
    );
  }

  Future<void> showProductReadyAlert(String produk, int jumlah) async {
    await _show(
      id: 3,
      title: '✅ Produk Siap Jual',
      body: '$jumlah unit $produk siap dipasarkan!',
    );
  }

  Future<void> _show({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'duck_farm_channel',
      'Duck Farm Alerts',
      channelDescription: 'Notifikasi manajemen peternakan bebek',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }
}
