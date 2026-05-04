// lib/data/database/dao/produksi_dao.dart

import '../database_helper.dart';

class ProduksiDao {
  final _db = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _db.database;
    return await db.insert('produksi_telur', data);
  }

  Future<List<Map<String, dynamic>>> getAll(int userId) async {
    final db = await _db.database;
    return await db.rawQuery(
      '''
      SELECT pt.*, k.nama AS nama_kandang
      FROM produksi_telur pt
      JOIN kandang k ON k.id = pt.kandang_id
      WHERE pt.user_id = ?
      ORDER BY pt.tanggal DESC
    ''',
      [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getByKandang(int kandangId) async {
    final db = await _db.database;
    return await db.query(
      'produksi_telur',
      where: 'kandang_id = ?',
      whereArgs: [kandangId],
      orderBy: 'tanggal DESC',
    );
  }

  // Ambil data 30 hari terakhir untuk prediksi AI
  Future<List<int>> getLast30Days(int kandangId) async {
    final db = await _db.database;
    final cutoff = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String();
    final result = await db.query(
      'produksi_telur',
      columns: ['jumlah_telur'],
      where: 'kandang_id = ? AND tanggal >= ?',
      whereArgs: [kandangId, cutoff],
      orderBy: 'tanggal ASC',
    );
    return result.map((r) => (r['jumlah_telur'] as int)).toList();
  }

  // Rata-rata produksi 7 hari terakhir
  Future<double> getAvgLast7Days(int kandangId) async {
    final db = await _db.database;
    final cutoff = DateTime.now()
        .subtract(const Duration(days: 7))
        .toIso8601String();
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(AVG(jumlah_telur), 0) AS avg_telur
      FROM produksi_telur
      WHERE kandang_id = ? AND tanggal >= ?
    ''',
      [kandangId, cutoff],
    );
    return (result.first['avg_telur'] as num? ?? 0).toDouble();
  }

  // Total produksi hari ini (semua kandang)
  Future<int> getTotalToday(int userId) async {
    final db = await _db.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(pt.jumlah_telur), 0) AS total
      FROM produksi_telur pt
      JOIN kandang k ON k.id = pt.kandang_id
      WHERE k.user_id = ? AND pt.tanggal LIKE ?
    ''',
      [userId, '$today%'],
    );
    return (result.first['total'] as num? ?? 0).toInt();
  }

  // Grafik 7 hari terakhir (per tanggal)
  Future<List<Map<String, dynamic>>> getChart7Days(int userId) async {
    final db = await _db.database;
    final cutoff = DateTime.now()
        .subtract(const Duration(days: 7))
        .toIso8601String();
    return await db.rawQuery(
      '''
      SELECT 
        DATE(pt.tanggal) AS tgl,
        SUM(pt.jumlah_telur) AS total
      FROM produksi_telur pt
      JOIN kandang k ON k.id = pt.kandang_id
      WHERE k.user_id = ? AND pt.tanggal >= ?
      GROUP BY DATE(pt.tanggal)
      ORDER BY tgl ASC
    ''',
      [userId, cutoff],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('produksi_telur', where: 'id = ?', whereArgs: [id]);
  }
}
