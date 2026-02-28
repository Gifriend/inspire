import 'package:freezed_annotation/freezed_annotation.dart';

part 'khs_model.freezed.dart';
part 'khs_model.g.dart';

@freezed
abstract class KhsMahasiswaModel with _$KhsMahasiswaModel {
  const factory KhsMahasiswaModel({
    required String nama,
    required String nim,
    required String angkatan,
    required String prodi,
    String? pembimbingAkademik,
  }) = _KhsMahasiswaModel;

  factory KhsMahasiswaModel.fromJson(Map<String, dynamic> json) =>
      _$KhsMahasiswaModelFromJson(json);
}

@freezed
abstract class KhsStatistikModel with _$KhsStatistikModel {
  const factory KhsStatistikModel({
    required int totalSks,
    required double totalNilaiSks,
    required double ips,
    required double ipk,
    required int maksBebaSksBerikutnya,
  }) = _KhsStatistikModel;

  factory KhsStatistikModel.fromJson(Map<String, dynamic> json) =>
      _$KhsStatistikModelFromJson(json);
}

@freezed
abstract class KhsNilaiItemModel with _$KhsNilaiItemModel {
  const factory KhsNilaiItemModel({
    required int no,
    required String kodeMk,
    required String namaMk,
    required int sks,
    required String nilaiHuruf,
    required double indeks,
    required double nilaiSks,
  }) = _KhsNilaiItemModel;

  factory KhsNilaiItemModel.fromJson(Map<String, dynamic> json) =>
      _$KhsNilaiItemModelFromJson(json);
}

@freezed
abstract class KhsModel with _$KhsModel {
  const factory KhsModel({
    required String semester,
    required KhsMahasiswaModel mahasiswa,
    required KhsStatistikModel statistik,
    required List<KhsNilaiItemModel> nilai,
  }) = _KhsModel;

  factory KhsModel.fromJson(Map<String, dynamic> json) =>
      _$KhsModelFromJson(json);
}


