class KandangModel {
  final int?    id;
  final String  nama;
  final int     kapasitas;
  final String? lokasi;
  final double? latitude;
  final double? longitude;
  final String? deskripsi;
  final int     userId;
  final String  createdAt;
  // From JOIN
  final int     totalBebek;
 
  KandangModel({
    this.id,
    required this.nama,
    required this.kapasitas,
    this.lokasi,
    this.latitude,
    this.longitude,
    this.deskripsi,
    required this.userId,
    required this.createdAt,
    this.totalBebek = 0,
  });
 
  factory KandangModel.fromMap(Map<String, dynamic> m) => KandangModel(
        id:         m['id'],
        nama:       m['nama'],
        kapasitas:  m['kapasitas'],
        lokasi:     m['lokasi'],
        latitude:   m['latitude'] != null ? (m['latitude'] as num).toDouble() : null,
        longitude:  m['longitude'] != null ? (m['longitude'] as num).toDouble() : null,
        deskripsi:  m['deskripsi'],
        userId:     m['user_id'],
        createdAt:  m['created_at'],
        totalBebek: (m['total_bebek'] as num? ?? 0).toInt(),
      );
 
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'nama':       nama,
        'kapasitas':  kapasitas,
        'lokasi':     lokasi,
        'latitude':   latitude,
        'longitude':  longitude,
        'deskripsi':  deskripsi,
        'user_id':    userId,
        'created_at': createdAt,
      };
}
 