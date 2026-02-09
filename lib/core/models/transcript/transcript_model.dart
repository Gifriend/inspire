import 'package:freezed_annotation/freezed_annotation.dart';

part 'transcript_model.freezed.dart';
part 'transcript_model.g.dart';

// Model untuk data mahasiswa
@freezed
abstract class MahasiswaInfoModel with _$MahasiswaInfoModel {
  const factory MahasiswaInfoModel({
    required String nama,
    required String nim,
    required String prodi,
    required String fakultas,
  }) = _MahasiswaInfoModel;

  factory MahasiswaInfoModel.fromJson(Map<String, dynamic> json) =>
      _$MahasiswaInfoModelFromJson(json);
}

// Model untuk statistik
@freezed
abstract class StatistikModel with _$StatistikModel {
  const factory StatistikModel({
    required int totalSKS,
    required int totalMataKuliah,
    required String ipk,
    required String predikat,
  }) = _StatistikModel;

  factory StatistikModel.fromJson(Map<String, dynamic> json) =>
      _$StatistikModelFromJson(json);
}

// Model untuk item transkrip
@freezed
abstract class TranskripItemModel with _$TranskripItemModel {
  const factory TranskripItemModel({
    required String kode,
    required String matakuliah,
    required int sks,
    required String nilaiHuruf,
    required double indeksNilai,
    required String semester,
  }) = _TranskripItemModel;

  factory TranskripItemModel.fromJson(Map<String, dynamic> json) =>
      _$TranskripItemModelFromJson(json);
}

// Model utama transkrip (response dari backend)
@freezed
abstract class TranscriptSummaryModel with _$TranscriptSummaryModel {
  const factory TranscriptSummaryModel({
    required MahasiswaInfoModel mahasiswa,
    required StatistikModel statistik,
    required List<TranskripItemModel> transkrip,
  }) = _TranscriptSummaryModel;

  factory TranscriptSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$TranscriptSummaryModelFromJson(json);
}
