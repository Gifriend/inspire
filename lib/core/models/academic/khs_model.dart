import 'package:freezed_annotation/freezed_annotation.dart';

part 'khs_model.freezed.dart';
part 'khs_model.g.dart';

@freezed
abstract class KhsModel with _$KhsModel {
  const factory KhsModel({
    required String semester,
    required int totalSks,
    required double totalBobot,
    required double ips,
    required double ipk,
    required MahasiswaKhsModel mahasiswa,
    @Default([]) List<NilaiKhsModel> nilai,
  }) = _KhsModel;

  factory KhsModel.fromJson(Map<String, dynamic> json) =>
      _$KhsModelFromJson(json);
}

@freezed
abstract class MahasiswaKhsModel with _$MahasiswaKhsModel {
  const factory MahasiswaKhsModel({
    required String nama,
    required String nim,
    required String prodi,
  }) = _MahasiswaKhsModel;

  factory MahasiswaKhsModel.fromJson(Map<String, dynamic> json) =>
      _$MahasiswaKhsModelFromJson(json);
}

@freezed
abstract class NilaiKhsModel with _$NilaiKhsModel {
  const factory NilaiKhsModel({
    required String kodeMk,
    required String namaMk,
    required int sks,
    required String nilaiHuruf,
    required double indeks,
  }) = _NilaiKhsModel;

  factory NilaiKhsModel.fromJson(Map<String, dynamic> json) =>
      _$NilaiKhsModelFromJson(json);
}
