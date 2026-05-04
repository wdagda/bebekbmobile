class ProduksiModel {
  final int?   id;
  final int    kandangId;
  final String tanggal;
  final int    jumlahTelur;
  final String? catatan;
  final String? cuaca;
  final double? suhu;
  final int    userId;
  final String createdAt;
  // From JOIN
  final String? namaKandang;
 
  ProduksiModel({
    this.id,
    required this.kandangId,
    required this.tanggal,
    required this.jumlahTelur,
    this.catatan,
    this.cuaca,
    this.suhu,
    required this.userId,
    required this.createdAt,
    this.namaKandang,
  });
 
  factory ProduksiModel.fromMap(Map<String, dynamic> m) => ProduksiModel(
        id:          m['id'],
        kandangId:   m['kandang_id'],
        tanggal:     m['tanggal'],
        jumlahTelur: m['jumlah_telur'],
        catatan:     m['catatan'],
        cuaca:       m['cuaca'],
        suhu:        m['suhu'] != null ? (m['suhu'] as num).toDouble() : null,
        userId:      m['user_id'],
        createdAt:   m['created_at'],
        namaKandang: m['nama_kandang'],
      );
 
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'kandang_id':  kandangId,
        'tanggal':     tanggal,
        'jumlah_telur': jumlahTelur,
        'catatan':     catatan,
        'cuaca':       cuaca,
        'suhu':        suhu,
        'user_id':     userId,
        'created_at':  createdAt,
      };
}
 