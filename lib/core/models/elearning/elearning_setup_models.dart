import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/elearning/elearning_class_config_model.dart';
import 'package:inspire/core/models/elearning/elearning_lecturer_models.dart';
import 'package:inspire/core/models/elearning/course_list_model.dart';

part 'elearning_setup_models.freezed.dart';
part 'elearning_setup_models.g.dart';

// ─── Response Models ──────────────────────────────────────────────────────────

/// Data kelas dosen dari `GET /elearning/lecturer/courses`.
/// Menyertakan konfigurasi e-learning dan jumlah KRS & sesi.
@freezed
abstract class LecturerCourseModel with _$LecturerCourseModel {
  const factory LecturerCourseModel({
    required int id,
    required String nama,
    int? kapasitas,
    String? ruangan,
    String? jadwal,
    String? academicYear,
    required int mataKuliahId,
    int? dosenId,
    required DateTime createdAt,
    required DateTime updatedAt,
    MataKuliahInfoModel? mataKuliah,
    ElearningClassConfigModel? elearningConfig,
    LecturerCourseCountModel? count,
  }) = _LecturerCourseModel;

  /// Custom [fromJson] agar field `_count` (Prisma) dipetakan ke [count].
  factory LecturerCourseModel.fromJson(Map<String, dynamic> json) {
    final countData = json['_count'] as Map<String, dynamic>?;
    return LecturerCourseModel(
      id: json['id'] as int,
      nama: json['nama'] as String,
      kapasitas: json['kapasitas'] as int?,
      ruangan: json['ruangan'] as String?,
      jadwal: json['jadwal'] as String?,
      academicYear: json['academicYear'] as String?,
      mataKuliahId: json['mataKuliahId'] as int,
      dosenId: json['dosenId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      mataKuliah: json['mataKuliah'] == null
          ? null
          : MataKuliahInfoModel.fromJson(
              json['mataKuliah'] as Map<String, dynamic>,
            ),
      elearningConfig: json['elearningConfig'] == null
          ? null
          : ElearningClassConfigModel.fromJson(
              json['elearningConfig'] as Map<String, dynamic>,
            ),
      count: countData != null
          ? LecturerCourseCountModel.fromJson(countData)
          : null,
    );
  }
}

/// Jumlah KRS (mahasiswa terdaftar) dan sesi pada sebuah kelas dosen.
@freezed
abstract class LecturerCourseCountModel with _$LecturerCourseCountModel {
  const factory LecturerCourseCountModel({
    required int krs,
    required int sessions,
  }) = _LecturerCourseCountModel;

  factory LecturerCourseCountModel.fromJson(Map<String, dynamic> json) =>
      _$LecturerCourseCountModelFromJson(json);
}

/// Submission mahasiswa beserta info profil singkat.
/// Digunakan dosen pada `GET /elearning/assignment/:id/submissions`.
@freezed
abstract class SubmissionWithStudentModel with _$SubmissionWithStudentModel {
  const factory SubmissionWithStudentModel({
    required String id,
    required int studentId,
    required String assignmentId,
    String? fileUrl,
    String? textContent,
    double? grade,
    String? feedback,
    required DateTime submittedAt,
    DateTime? gradedAt,
    StudentInfoModel? student,
  }) = _SubmissionWithStudentModel;

  factory SubmissionWithStudentModel.fromJson(Map<String, dynamic> json) =>
      _$SubmissionWithStudentModelFromJson(json);
}

/// Percobaan kuis mahasiswa beserta info profil singkat.
/// Digunakan dosen pada `GET /elearning/quiz/:id/attempts`.
@freezed
abstract class QuizAttemptWithStudentModel with _$QuizAttemptWithStudentModel {
  const factory QuizAttemptWithStudentModel({
    required String id,
    required int studentId,
    required String quizId,
    required num score,
    required DateTime startedAt,
    DateTime? finishedAt,
    StudentInfoModel? student,
  }) = _QuizAttemptWithStudentModel;

  factory QuizAttemptWithStudentModel.fromJson(Map<String, dynamic> json) =>
      _$QuizAttemptWithStudentModelFromJson(json);
}

/// Hasil operasi setup kelas e-learning.
@freezed
abstract class SetupElearningResultModel with _$SetupElearningResultModel {
  const factory SetupElearningResultModel({
    required String message,
    ElearningClassConfigModel? config,
    @Default(0) int clonedSessionCount,
  }) = _SetupElearningResultModel;

  factory SetupElearningResultModel.fromJson(Map<String, dynamic> json) =>
      _$SetupElearningResultModelFromJson(json);
}

/// Hasil operasi merge kelas e-learning.
@freezed
abstract class MergeElearningResultModel with _$MergeElearningResultModel {
  const factory MergeElearningResultModel({
    required String message,
    required int masterKelasPerkuliahanId,
    @Default([]) List<int> mergedClassIds,
  }) = _MergeElearningResultModel;

  factory MergeElearningResultModel.fromJson(Map<String, dynamic> json) =>
      _$MergeElearningResultModelFromJson(json);
}

// ─── Request DTOs ─────────────────────────────────────────────────────────────
// Plain Dart — tidak perlu generator, hanya serialisasi ke JSON.

extension _SetupModeJson on ElearningSetupMode {
  String get jsonValue => switch (this) {
        ElearningSetupMode.newClass => 'NEW',
        ElearningSetupMode.existing => 'EXISTING',
      };
}

extension _EntityTypeJson on ElearningEntityType {
  String get jsonValue => switch (this) {
        ElearningEntityType.material => 'MATERIAL',
        ElearningEntityType.assignment => 'ASSIGNMENT',
        ElearningEntityType.quiz => 'QUIZ',
      };
}

/// DTO untuk `POST /elearning/setup/class`.
class SetupElearningClassRequest {
  final int kelasPerkuliahanId;
  final ElearningSetupMode setupMode;

  /// Wajib diisi jika [setupMode] = [ElearningSetupMode.existing].
  final int? sourceKelasPerkuliahanId;

  /// Jika [true], kelas ini hanya mengikuti sumber tanpa clone.
  final bool? isMergedClass;

  /// Jika [true], seluruh konten clone tersembunyi (hidden) secara default.
  final bool? cloneContentAsHidden;

  const SetupElearningClassRequest({
    required this.kelasPerkuliahanId,
    required this.setupMode,
    this.sourceKelasPerkuliahanId,
    this.isMergedClass,
    this.cloneContentAsHidden,
  });

  Map<String, dynamic> toJson() => {
        'kelasPerkuliahanId': kelasPerkuliahanId,
        'setupMode': setupMode.jsonValue,
        if (sourceKelasPerkuliahanId != null)
          'sourceKelasPerkuliahanId': sourceKelasPerkuliahanId,
        if (isMergedClass != null) 'isMergedClass': isMergedClass,
        if (cloneContentAsHidden != null)
          'cloneContentAsHidden': cloneContentAsHidden,
      };
}

/// DTO untuk `POST /elearning/setup/merge`.
class MergeElearningClassesRequest {
  final int masterKelasPerkuliahanId;
  final List<int> memberKelasPerkuliahanIds;

  const MergeElearningClassesRequest({
    required this.masterKelasPerkuliahanId,
    required this.memberKelasPerkuliahanIds,
  });

  Map<String, dynamic> toJson() => {
        'masterKelasPerkuliahanId': masterKelasPerkuliahanId,
        'memberKelasPerkuliahanIds': memberKelasPerkuliahanIds,
      };
}

/// DTO untuk `PATCH /elearning/setup/visibility`.
/// Digunakan untuk hide/show item (materi / tugas / kuis) per item.
class ToggleVisibilityRequest {
  final ElearningEntityType entityType;
  final String entityId;
  final bool isHidden;

  const ToggleVisibilityRequest({
    required this.entityType,
    required this.entityId,
    required this.isHidden,
  });

  Map<String, dynamic> toJson() => {
        'entityType': entityType.jsonValue,
        'entityId': entityId,
        'isHidden': isHidden,
      };
}

/// DTO untuk `PATCH /elearning/submission/:id/grade`.
class GradeSubmissionRequest {
  final double grade;
  final String? feedback;

  const GradeSubmissionRequest({required this.grade, this.feedback});

  Map<String, dynamic> toJson() => {
        'grade': grade,
        if (feedback != null) 'feedback': feedback,
      };
}
