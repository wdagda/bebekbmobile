
class PakanModel {
  final int?   id;
  final int    kandangId;
  final String namaPakan;
  final double stokKg;
  final double batasMinKg;
  final double hargaPerKg;
  final String updatedAt;
  final String? namaKandang;
 
  PakanModel({
    this.id,
    required this.kandangId,
    required this.namaPakan,
    required this.stokKg,
    this.batasMinKg = 10.0,
    this.hargaPerKg = 0,
    required this.updatedAt,
    this.namaKandang,
  });
 
  bool get isLow => stokKg <= batasMinKg;
 
  factory PakanModel.fromMap(Map<String, dynamic> m) => PakanModel(
        id:          m['id'],
        kandangId:   m['kandang_id'],
        namaPakan:   m['nama_pakan'],
        stokKg:      (m['stok_kg'] as num).toDouble(),
        batasMinKg:  (m['batas_min_kg'] as num? ?? 10.0).toDouble(),
        hargaPerKg:  (m['harga_per_kg'] as num? ?? 0).toDouble(),
        updatedAt:   m['updated_at'],
        namaKandang: m['nama_kandang'],
      );
 
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'kandang_id':   kandangId,
        'nama_pakan':   namaPakan,
        'stok_kg':      stokKg,
        'batas_min_kg': batasMinKg,
        'harga_per_kg': hargaPerKg,
        'updated_at':   updatedAt,
      };
}
 