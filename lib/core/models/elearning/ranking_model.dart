import 'package:freezed_annotation/freezed_annotation.dart';

part 'ranking_model.freezed.dart';
part 'ranking_model.g.dart';

@freezed
abstract class RankingDetailTugas with _$RankingDetailTugas {
  const factory RankingDetailTugas({
    required String id,
    required String title,
    @Default('TUGAS') String kategori,
    @Default(0.0) double bobot,
    double? nilai,
    @Default(0.0) double kontribusi,
  }) = _RankingDetailTugas;

  factory RankingDetailTugas.fromJson(Map<String, dynamic> json) =>
      _$RankingDetailTugasFromJson(json);
}


@freezed
abstract class RankingDetailKuis with _$RankingDetailKuis {
  const factory RankingDetailKuis({
    required String id,
    required String title,
    @Default('KUIS') String kategori,
    @Default(0.0) double bobot,
    double? scorePercentage,
    @Default(0.0) double kontribusi,
  }) = _RankingDetailKuis;

  factory RankingDetailKuis.fromJson(Map<String, dynamic> json) =>
      _$RankingDetailKuisFromJson(json);
}


@freezed
abstract class RankingEntry with _$RankingEntry {
  const factory RankingEntry({
    required int rank,
    required int mahasiswaId,
    required String nama,
    @Default('-') String nim,
    @Default(0.0) double totalNilai,
    required List<RankingDetailTugas> detailTugas,
    required List<RankingDetailKuis> detailKuis,
  }) = _RankingEntry;

  factory RankingEntry.fromJson(Map<String, dynamic> json) =>
      _$RankingEntryFromJson(json);
}


@freezed
abstract class RankingData with _$RankingData {
  const factory RankingData({
    required int kelasId,
    @Default('') String namaKelas,
    @Default('') String kodeMK,
    @Default('') String namaMK,
    @Default('') String academicYear,
    @Default('') String dosenNama,
    @Default(0.0) double totalBobot,
    String? catatan,
    required List<RankingEntry> ranking,
  }) = _RankingData;

  factory RankingData.fromJson(Map<String, dynamic> json) =>
      _$RankingDataFromJson(json);
}
