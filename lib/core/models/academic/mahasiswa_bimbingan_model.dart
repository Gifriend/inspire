/// Model untuk daftar mahasiswa bimbingan PA
/// Response dari GET /academic/pa/mahasiswa
class MahasiswaBimbinganModel {
  final int id;
  final String nama;
  final String nim;
  final String prodi;
  final String angkatan;
  final String status;
  final double ipk;
  final int totalSksLulus;
  final String? semesterTerakhir;

  const MahasiswaBimbinganModel({
    required this.id,
    required this.nama,
    required this.nim,
    required this.prodi,
    required this.angkatan,
    required this.status,
    required this.ipk,
    required this.totalSksLulus,
    this.semesterTerakhir,
  });

  factory MahasiswaBimbinganModel.fromJson(Map<String, dynamic> json) {
    return MahasiswaBimbinganModel(
      id: (json['id'] as num).toInt(),
      nama: json['nama'] as String? ?? '-',
      nim: json['nim'] as String? ?? '-',
      prodi: json['prodi'] as String? ?? '-',
      angkatan: json['angkatan'] as String? ?? '-',
      status: json['status'] as String? ?? '-',
      ipk: (json['ipk'] as num?)?.toDouble() ?? 0.0,
      totalSksLulus: (json['totalSksLulus'] as num?)?.toInt() ?? 0,
      semesterTerakhir: json['semesterTerakhir'] as String?,
    );
  }
}
