class TransaksiModel {
  final int? id;
  final String jenis; // PRODUKSI, KONVERSI, PENJUALAN, PAKAN
  final int? produkId;
  final int? kandangId;
  final double jumlah;
  final String? keterangan;
  final int userId;
  final String createdAt;

  TransaksiModel({
    this.id,
    required this.jenis,
    this.produkId,
    this.kandangId,
    required this.jumlah,
    this.keterangan,
    required this.userId,
    required this.createdAt,
  });

  factory TransaksiModel.fromMap(Map<String, dynamic> m) => TransaksiModel(
    id: m['id'],
    jenis: m['jenis'],
    produkId: m['produk_id'],
    kandangId: m['kandang_id'],
    jumlah: (m['jumlah'] as num? ?? 0).toDouble(),
    keterangan: m['keterangan'],
    userId: m['user_id'],
    createdAt: m['created_at'],
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'jenis': jenis,
    'produk_id': produkId,
    'kandang_id': kandangId,
    'jumlah': jumlah,
    'keterangan': keterangan,
    'user_id': userId,
    'created_at': createdAt,
  };
}
