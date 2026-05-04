// lib/data/database/dao/user_dao.dart

import '../database_helper.dart';

class UserDao {
  final _db = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> user) async {
    final db = await _db.database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> findByUsername(String username) async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> findById(int id) async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateFoto(int userId, String fotoPath) async {
    final db = await _db.database;
    return await db.update(
      'users',
      {'foto_path': fotoPath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateFullName(int userId, String fullName) async {
    final db = await _db.database;
    return await db.update(
      'users',
      {'full_name': fullName},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateBiometric(int userId, bool enabled) async {
    final db = await _db.database;
    return await db.update(
      'users',
      {'biometric_enabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updatePassword(int userId, String newHash) async {
    final db = await _db.database;
    return await db.update(
      'users',
      {'password_hash': newHash},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
