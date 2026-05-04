// lib/data/database/dao/pakan_dao.dart

import '../database_helper.dart';
import '../../core/services/notification_service.dart';

class PakanDao {
  final _db = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _db.database;
    return await db.insert('stok_pakan', data);
  }

  Future<List<Map<String, dynamic>>> getByKandang(int kandangId) async {
    final db = await _db.database;
    return await db.query(
      'stok_pakan',
      where: 'kandang_id = ?',
      whereArgs: [kandangId],
      orderBy: 'nama_pakan ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAll(int userId) async {
    final db = await _db.database;
    return await db.rawQuery(
      '''
      SELECT sp.*, k.nama AS nama_kandang
      FROM stok_pakan sp
      JOIN kandang k ON k.id = sp.kandang_id
      WHERE k.user_id = ?
      ORDER BY sp.stok_kg ASC
    ''',
      [userId],
    );
  }

  Future<int> updateStok(int id, double stokBaru, String namaKandang) async {
    final db = await _db.database;

    // Ambil batas minimum
    final current = await db.query(
      'stok_pakan',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (current.isNotEmpty) {
      final batasMin = (current.first['batas_min_kg'] as num).toDouble();
      if (stokBaru <= batasMin) {
        NotificationService.instance.showLowStockAlert(namaKandang, stokBaru);
      }
    }

    return await db.update(
      'stok_pakan',
      {'stok_kg': stokBaru, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> update(Map<String, dynamic> data) async {
    final db = await _db.database;
    return await db.update(
      'stok_pakan',
      {...data, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('stok_pakan', where: 'id = ?', whereArgs: [id]);
  }

  // Cek semua stok yang hampir habis
  Future<List<Map<String, dynamic>>> getLowStock(int userId) async {
    final db = await _db.database;
    return await db.rawQuery(
      '''
      SELECT sp.*, k.nama AS nama_kandang
      FROM stok_pakan sp
      JOIN kandang k ON k.id = sp.kandang_id
      WHERE k.user_id = ? AND sp.stok_kg <= sp.batas_min_kg
    ''',
      [userId],
    );
  }
}
