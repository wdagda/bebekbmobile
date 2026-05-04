// lib/data/database/dao/kandang_dao.dart

import '../database_helper.dart';

class KandangDao {
  final _db = DatabaseHelper.instance;

  // INSERT
  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _db.database;
    return await db.insert('kandang', data);
  }

  // GET ALL (join dengan jumlah bebek)
  Future<List<Map<String, dynamic>>> getAll(int userId) async {
    final db = await _db.database;
    return await db.rawQuery('''
      SELECT 
        k.*,
        COALESCE(SUM(b.jumlah), 0) AS total_bebek,
        (SELECT COUNT(*) FROM produksi_telur pt WHERE pt.kandang_id = k.id) AS total_produksi
      FROM kandang k
      LEFT JOIN bebek b ON b.kandang_id = k.id AND b.status = 'aktif'
      WHERE k.user_id = ?
      GROUP BY k.id
      ORDER BY k.created_at DESC
    ''', [userId]);
  }

  // GET BY ID
  Future<Map<String, dynamic>?> getById(int id) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT 
        k.*,
        COALESCE(SUM(b.jumlah), 0) AS total_bebek
      FROM kandang k
      LEFT JOIN bebek b ON b.kandang_id = k.id AND b.status = 'aktif'
      WHERE k.id = ?
      GROUP BY k.id
    ''', [id]);
    return result.isNotEmpty ? result.first : null;
  }

  // UPDATE
  Future<int> update(Map<String, dynamic> data) async {
    final db = await _db.database;
    return await db.update(
      'kandang',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('kandang', where: 'id = ?', whereArgs: [id]);
  }

  // SEARCH
  Future<List<Map<String, dynamic>>> search(String keyword, int userId) async {
    final db = await _db.database;
    return await db.query(
      'kandang',
      where: 'nama LIKE ? AND user_id = ?',
      whereArgs: ['%$keyword%', userId],
    );
  }

  // GET ALL WITH COORDS (untuk maps)
  Future<List<Map<String, dynamic>>> getAllWithCoords(int userId) async {
    final db = await _db.database;
    return await db.query(
      'kandang',
      where: 'user_id = ? AND latitude IS NOT NULL AND longitude IS NOT NULL',
      whereArgs: [userId],
    );
  }
}