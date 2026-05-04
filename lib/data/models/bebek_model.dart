class BebekModel {
  final int?   id;
  final int    kandangId;
  final int    jumlah;
  final String jenis;
  final String tanggalMasuk;
  final String status;
 
  BebekModel({
    this.id,
    required this.kandangId,
    required this.jumlah,
    this.jenis = 'petelur',
    required this.tanggalMasuk,
    this.status = 'aktif',
  });
 
  factory BebekModel.fromMap(Map<String, dynamic> m) => BebekModel(
        id:           m['id'],
        kandangId:    m['kandang_id'],
        jumlah:       m['jumlah'],
        jenis:        m['jenis'] ?? 'petelur',
        tanggalMasuk: m['tanggal_masuk'],
        status:       m['status'] ?? 'aktif',
      );
 
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'kandang_id':   kandangId,
        'jumlah':       jumlah,
        'jenis':        jenis,
        'tanggal_masuk': tanggalMasuk,
        'status':       status,
      };
}
 