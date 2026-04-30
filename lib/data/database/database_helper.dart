import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'duck_farm.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        foto_path TEXT,
        role TEXT DEFAULT 'owner',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE kandang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        kapasitas INTEGER NOT NULL,
        lokasi TEXT,
        latitude REAL,
        longitude REAL,
        deskripsi TEXT,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE bebek (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kandang_id INTEGER NOT NULL,
        jumlah INTEGER NOT NULL,
        jenis TEXT DEFAULT 'petelur',
        tanggal_masuk TEXT NOT NULL,
        status TEXT DEFAULT 'aktif',
        FOREIGN KEY (kandang_id) REFERENCES kandang(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE produksi_telur (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kandang_id INTEGER NOT NULL,
        tanggal TEXT NOT NULL,
        jumlah_telur INTEGER NOT NULL,
        catatan TEXT,
        cuaca TEXT,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (kandang_id) REFERENCES kandang(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE stok_pakan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kandang_id INTEGER NOT NULL,
        nama_pakan TEXT NOT NULL,
        stok_kg REAL NOT NULL,
        batas_min_kg REAL DEFAULT 10.0,
        harga_per_kg REAL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (kandang_id) REFERENCES kandang(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE produk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        jenis TEXT NOT NULL CHECK(jenis IN ('MENTAH', 'ASIN', 'KERUPUK')),
        stok_unit INTEGER DEFAULT 0,
        harga_jual REAL,
        kandang_id INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (kandang_id) REFERENCES kandang(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE riwayat_transaksi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jenis TEXT NOT NULL,
        produk_id INTEGER,
        kandang_id INTEGER,
        jumlah REAL,
        keterangan TEXT,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE feedback (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        pesan TEXT NOT NULL,
        rating INTEGER DEFAULT 5,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here
  }
}
