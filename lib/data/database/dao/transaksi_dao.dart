// lib/data/database/dao/transaksi_dao.dart

import '../database_helper.dart';

class TransaksiDao {
  final _db = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _db.database;
    return await db.insert('riwayat_transaksi', data);
  }

  Future<List<Map<String, dynamic>>> getAll(int userId) async {
    final db = await _db.database;
    return await db.query(
      'riwayat_transaksi',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getByJenis(
    String jenis,
    int userId,
  ) async {
    final db = await _db.database;
    return await db.query(
      'riwayat_transaksi',
      where: 'jenis = ? AND user_id = ?',
      whereArgs: [jenis, userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> search(String keyword, int userId) async {
    final db = await _db.database;
    return await db.query(
      'riwayat_transaksi',
      where: 'keterangan LIKE ? AND user_id = ?',
      whereArgs: ['%$keyword%', userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'riwayat_transaksi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class FeedbackDao {
  final _db = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _db.database;
    return await db.insert('feedback', data);
  }

  Future<List<Map<String, dynamic>>> getAll(int userId) async {
    final db = await _db.database;
    return await db.query(
      'feedback',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<double> getAvgRating(int userId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(AVG(rating), 0) AS avg FROM feedback WHERE user_id = ?',
      [userId],
    );
    return (result.first['avg'] as num? ?? 0).toDouble();
  }
}
