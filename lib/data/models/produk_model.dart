enum JenisProduk { MENTAH, ASIN, KERUPUK }

class ProdukModel {
  final int? id;
  final String nama;
  final JenisProduk jenis;
  final int stokUnit;
  final double hargaJual;
  final int? kandangId;
  final String createdAt;
  final String? namaKandang;

  ProdukModel({
    this.id,
    required this.nama,
    required this.jenis,
    this.stokUnit = 0,
    this.hargaJual = 0,
    this.kandangId,
    required this.createdAt,
    this.namaKandang,
  });

  String get jenisLabel {
    switch (jenis) {
      case JenisProduk.MENTAH:
        return 'Telur Mentah';
      case JenisProduk.ASIN:
        return 'Telur Asin';
      case JenisProduk.KERUPUK:
        return 'Kerupuk Telur';
    }
  }

  factory ProdukModel.fromMap(Map<String, dynamic> m) => ProdukModel(
    id: m['id'],
    nama: m['nama'],
    jenis: JenisProduk.values.firstWhere(
      (e) => e.name == m['jenis'],
      orElse: () => JenisProduk.MENTAH,
    ),
    stokUnit: m['stok_unit'] ?? 0,
    hargaJual: (m['harga_jual'] as num? ?? 0).toDouble(),
    kandangId: m['kandang_id'],
    createdAt: m['created_at'],
    namaKandang: m['nama_kandang'],
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'nama': nama,
    'jenis': jenis.name,
    'stok_unit': stokUnit,
    'harga_jual': hargaJual,
    'kandang_id': kandangId,
    'created_at': createdAt,
  };
}
