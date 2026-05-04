// lib/data/database/dao/bebek_dao.dart

import '../database_helper.dart';

class BebekDao {
  final _db = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _db.database;
    return await db.insert('bebek', data);
  }

  Future<List<Map<String, dynamic>>> getByKandang(int kandangId) async {
    final db = await _db.database;
    return await db.query(
      'bebek',
      where: 'kandang_id = ?',
      whereArgs: [kandangId],
      orderBy: 'tanggal_masuk DESC',
    );
  }

  Future<int> getTotalByKandang(int kandangId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(jumlah), 0) AS total FROM bebek WHERE kandang_id = ? AND status = ?',
      [kandangId, 'aktif'],
    );
    return (result.first['total'] as num? ?? 0).toInt();
  }

  Future<int> update(Map<String, dynamic> data) async {
    final db = await _db.database;
    return await db.update(
      'bebek',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('bebek', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateJumlah(int id, int jumlahBaru) async {
    final db = await _db.database;
    return await db.update(
      'bebek',
      {'jumlah': jumlahBaru},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
