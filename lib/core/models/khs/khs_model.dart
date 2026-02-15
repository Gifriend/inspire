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
    required MahasiswaInfoModel mahasiswa,
    required List<NilaiItemModel> nilai,
  }) = _KhsModel;

  factory KhsModel.fromJson(Map<String, dynamic> json) =>
      _$KhsModelFromJson(json);
}

@freezed
abstract class MahasiswaInfoModel with _$MahasiswaInfoModel {
  const factory MahasiswaInfoModel({
    required String nama,
    required String nim,
    required String prodi,
  }) = _MahasiswaInfoModel;

  factory MahasiswaInfoModel.fromJson(Map<String, dynamic> json) =>
      _$MahasiswaInfoModelFromJson(json);
}

@freezed
abstract class NilaiItemModel with _$NilaiItemModel {
  const factory NilaiItemModel({
    required String kodeMk,
    required String namaMk,
    required int sks,
    required String nilaiHuruf,
    required double indeks,
  }) = _NilaiItemModel;

  factory NilaiItemModel.fromJson(Map<String, dynamic> json) =>
      _$NilaiItemModelFromJson(json);
}


