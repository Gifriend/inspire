import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/constants/constants.dart';

part 'krs_lecturer_model.freezed.dart';
part 'krs_lecturer_model.g.dart';

/// KRS item returned by the PA-filtered endpoints.
/// List endpoint returns [matakuliah]; detail endpoint returns [kelasPerkuliahan].
@freezed
abstract class KrsSubmissionModel with _$KrsSubmissionModel {
  const factory KrsSubmissionModel({
    required int id,
    required String academicYear,
    required StatusKRS status,
    required int totalSKS,
    DateTime? tanggalPengajuan,
    DateTime? tanggalPersetujuan,
    String? catatanDosen,
    MahasiswaInfo? mahasiswa,
    @Default([]) List<KrsMatakuliahItem> matakuliah,
    @Default([]) List<KrsKelasDetailItem> kelasPerkuliahan,
  }) = _KrsSubmissionModel;

  factory KrsSubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$KrsSubmissionModelFromJson(json);
}

/// Student info embedded in KRS.
/// List endpoint: id, nama, nim, ipk, totalSksLulus.
/// Detail endpoint: id, nama, nim.
@freezed
abstract class MahasiswaInfo with _$MahasiswaInfo {
  const factory MahasiswaInfo({
    required int id,
    required String nama,
    String? nim,
    double? ipk,
    int? totalSksLulus,
  }) = _MahasiswaInfo;

  factory MahasiswaInfo.fromJson(Map<String, dynamic> json) =>
      _$MahasiswaInfoFromJson(json);
}

/// MK item in the list response (GET /krs/pa/mahasiswa).
@freezed
abstract class KrsMatakuliahItem with _$KrsMatakuliahItem {
  const factory KrsMatakuliahItem({
    required int kelasId,
    required String kodeMK,
    required String namaMK,
    required int sks,
  }) = _KrsMatakuliahItem;

  factory KrsMatakuliahItem.fromJson(Map<String, dynamic> json) =>
      _$KrsMatakuliahItemFromJson(json);
}

/// Kelas item in the detail response (GET /krs/pa/detail/:krsId).
@freezed
abstract class KrsKelasDetailItem with _$KrsKelasDetailItem {
  const factory KrsKelasDetailItem({
    required int kelasId,
    required String kodeMK,
    required String namaMK,
    required int sks,
    String? namaKelas,
    String? dosenPengampu,
  }) = _KrsKelasDetailItem;

  factory KrsKelasDetailItem.fromJson(Map<String, dynamic> json) =>
      _$KrsKelasDetailItemFromJson(json);
}
