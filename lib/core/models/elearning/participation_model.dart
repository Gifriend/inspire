import 'package:freezed_annotation/freezed_annotation.dart';

part 'participation_model.freezed.dart';
part 'participation_model.g.dart';

@freezed
abstract class ParticipationEntry with _$ParticipationEntry {
  const factory ParticipationEntry({
    required int mahasiswaId,
    required String nama,
    required String nim,
    bool? submitted,
    double? nilai,
    DateTime? submittedAt,
    bool? attempted,
    double? score,
    double? scorePercentage,
    DateTime? finishedAt,
  }) = _ParticipationEntry;

  factory ParticipationEntry.fromJson(Map<String, dynamic> json) =>
      _$ParticipationEntryFromJson(json);

  factory ParticipationEntry.fromAssignmentJson(Map<String, dynamic> json) =>
      ParticipationEntry(
        mahasiswaId: (json['mahasiswaId'] as num).toInt(),
        nama: json['nama'] as String,
        nim: json['nim'] as String? ?? '-',
        submitted: json['submitted'] as bool?,
        nilai: (json['nilai'] as num?)?.toDouble(),
        submittedAt: json['submittedAt'] == null
            ? null
            : DateTime.parse(json['submittedAt'] as String),
      );

  factory ParticipationEntry.fromQuizJson(Map<String, dynamic> json) =>
      ParticipationEntry(
        mahasiswaId: (json['mahasiswaId'] as num).toInt(),
        nama: json['nama'] as String,
        nim: json['nim'] as String? ?? '-',
        attempted: json['attempted'] as bool?,
        score: (json['score'] as num?)?.toDouble(),
        scorePercentage: (json['scorePercentage'] as num?)?.toDouble(),
        finishedAt: json['finishedAt'] == null
            ? null
            : DateTime.parse(json['finishedAt'] as String),
      );
}


@freezed
abstract class AssignmentParticipation with _$AssignmentParticipation {
  const factory AssignmentParticipation({
    required String id,
    required String title,
    @Default('TUGAS') String kategori,
    @Default(0.0) double bobot,
    required DateTime deadline,
    required int pertemuan,
    required int totalMahasiswaTerdaftar,
    required int totalSubmitted,
    required List<ParticipationEntry> partisipasi,
  }) = _AssignmentParticipation;

  factory AssignmentParticipation.fromJson(Map<String, dynamic> json) =>
      _$AssignmentParticipationFromJson(json);
}


@freezed
abstract class QuizParticipation with _$QuizParticipation {
  const factory QuizParticipation({
    required String id,
    required String title,
    @Default('KUIS') String kategori,
    @Default(0.0) double bobot,
    required DateTime startTime,
    required DateTime endTime,
    @Default(0.0) double maxPoints,
    required int pertemuan,
    required int totalMahasiswaTerdaftar,
    required int totalAttempted,
    required List<ParticipationEntry> partisipasi,
  }) = _QuizParticipation;

  factory QuizParticipation.fromJson(Map<String, dynamic> json) =>
      _$QuizParticipationFromJson(json);
}


@freezed
abstract class ParticipationData with _$ParticipationData {
  const factory ParticipationData({
    required int kelasId,
    @Default('') String namaKelas,
    @Default('') String kodeMK,
    @Default('') String namaMK,
    @Default('') String academicYear,
    @Default('') String dosenNama,
    required int totalMahasiswa,
    required List<AssignmentParticipation> tugas,
    required List<QuizParticipation> kuis,
  }) = _ParticipationData;

  factory ParticipationData.fromJson(Map<String, dynamic> json) =>
      _$ParticipationDataFromJson(json);
}
