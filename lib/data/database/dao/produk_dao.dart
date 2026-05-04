// lib/data/database/dao/produk_dao.dart

import '../database_helper.dart';

class ProdukDao {
  final _db = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _db.database;
    return await db.insert('produk', data);
  }

  Future<List<Map<String, dynamic>>> getAll(int userId) async {
    final db = await _db.database;
    return await db.rawQuery(
      '''
      SELECT p.*, k.nama AS nama_kandang
      FROM produk p
      LEFT JOIN kandang k ON k.id = p.kandang_id
      WHERE k.user_id = ? OR p.kandang_id IS NULL
      ORDER BY p.jenis ASC, p.nama ASC
    ''',
      [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getByJenis(
    String jenis,
    int userId,
  ) async {
    final db = await _db.database;
    return await db.rawQuery(
      '''
      SELECT p.*
      FROM produk p
      LEFT JOIN kandang k ON k.id = p.kandang_id
      WHERE p.jenis = ? AND (k.user_id = ? OR p.kandang_id IS NULL)
    ''',
      [jenis, userId],
    );
  }

  Future<int> updateStok(int id, int stokBaru) async {
    final db = await _db.database;
    return await db.update(
      'produk',
      {'stok_unit': stokBaru},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> tambahStok(int id, int jumlah) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE produk SET stok_unit = stok_unit + ? WHERE id = ?',
      [jumlah, id],
    );
    return jumlah;
  }

  Future<int> kurangiStok(int id, int jumlah) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE produk SET stok_unit = stok_unit - ? WHERE id = ? AND stok_unit >= ?',
      [jumlah, id, jumlah],
    );
    return jumlah;
  }

  Future<int> update(Map<String, dynamic> data) async {
    final db = await _db.database;
    return await db.update(
      'produk',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('produk', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> search(String keyword, int userId) async {
    final db = await _db.database;
    return await db.rawQuery(
      '''
      SELECT p.*
      FROM produk p
      LEFT JOIN kandang k ON k.id = p.kandang_id
      WHERE p.nama LIKE ? AND (k.user_id = ? OR p.kandang_id IS NULL)
    ''',
      ['%$keyword%', userId],
    );
  }

  // Total stok semua produk per jenis
  Future<Map<String, int>> getStokSummary(int userId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      '''
      SELECT p.jenis, COALESCE(SUM(p.stok_unit), 0) AS total
      FROM produk p
      LEFT JOIN kandang k ON k.id = p.kandang_id
      WHERE k.user_id = ? OR p.kandang_id IS NULL
      GROUP BY p.jenis
    ''',
      [userId],
    );
    return {
      for (var r in result) r['jenis'] as String: (r['total'] as num).toInt(),
    };
  }
}
