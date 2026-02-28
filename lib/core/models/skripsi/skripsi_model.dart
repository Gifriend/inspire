import 'package:freezed_annotation/freezed_annotation.dart';

part 'skripsi_model.freezed.dart';
part 'skripsi_model.g.dart';

@freezed
abstract class SkripsiModel with _$SkripsiModel {
  const factory SkripsiModel({
    required int id,
    required String judul,
    String? abstrak,
    @Default('DRAFT') String statusPengajuan,
    DateTime? tanggalPengajuan,
    DateTime? tanggalSidang,
    double? nilaiAkhir,
    required int mahasiswaId,
    required int pembimbingUtamaId,
    int? coPembimbingId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SkripsiModel;

  factory SkripsiModel.fromJson(Map<String, dynamic> json) =>
      _$SkripsiModelFromJson(json);
}
