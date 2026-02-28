import 'package:freezed_annotation/freezed_annotation.dart';

part 'transcript_model.freezed.dart';
part 'transcript_model.g.dart';

// Model untuk data mahasiswa pada transkrip
@freezed
abstract class TranskripMahasiswaModel with _$TranskripMahasiswaModel {
  const factory TranskripMahasiswaModel({
    required String nama,
    required String nim,
    required String angkatan,
    required String jenisKelamin,
    String? tempatLahir,
    String? tanggalLahir,
    required String prodi,
    required String jenjang,
    required String fakultas,
    String? tanggalMasuk,
    required String tanggalCetak,
  }) = _TranskripMahasiswaModel;

  factory TranskripMahasiswaModel.fromJson(Map<String, dynamic> json) =>
      _$TranskripMahasiswaModelFromJson(json);
}

// Model untuk statistik transkrip
@freezed
abstract class TranskripStatistikModel with _$TranskripStatistikModel {
  const factory TranskripStatistikModel({
    required int totalSKS,
    required int totalMataKuliah,
    required String ipk,
    required String predikat,
  }) = _TranskripStatistikModel;

  factory TranskripStatistikModel.fromJson(Map<String, dynamic> json) =>
      _$TranskripStatistikModelFromJson(json);
}

// Model untuk item mata kuliah pada tiap semester
@freezed
abstract class TranskripMkItemModel with _$TranskripMkItemModel {
  const factory TranskripMkItemModel({
    required int no,
    required String kode,
    required String nama,
    required int sks,
    required String nilaiHuruf,
    required double indeks,
    required double nilaiSks,
  }) = _TranskripMkItemModel;

  factory TranskripMkItemModel.fromJson(Map<String, dynamic> json) =>
      _$TranskripMkItemModelFromJson(json);
}

// Model untuk sub-total per semester
@freezed
abstract class TranskripSubTotalModel with _$TranskripSubTotalModel {
  const factory TranskripSubTotalModel({
    required int sks,
    required double nilaiSks,
  }) = _TranskripSubTotalModel;

  factory TranskripSubTotalModel.fromJson(Map<String, dynamic> json) =>
      _$TranskripSubTotalModelFromJson(json);
}

// Model per semester dalam transkrip
@freezed
abstract class TranskripSemesterModel with _$TranskripSemesterModel {
  const factory TranskripSemesterModel({
    required int semesterKe,
    required String label,
    required String academicYear,
    required List<TranskripMkItemModel> matakuliah,
    required TranskripSubTotalModel subTotal,
  }) = _TranskripSemesterModel;

  factory TranskripSemesterModel.fromJson(Map<String, dynamic> json) =>
      _$TranskripSemesterModelFromJson(json);
}

// Model utama transkrip (response dari backend)
@freezed
abstract class TranscriptModel with _$TranscriptModel {
  const factory TranscriptModel({
    required TranskripMahasiswaModel mahasiswa,
    required TranskripStatistikModel statistik,
    required List<TranskripSemesterModel> bySemester,
  }) = _TranscriptModel;

  factory TranscriptModel.fromJson(Map<String, dynamic> json) =>
      _$TranscriptModelFromJson(json);
}
