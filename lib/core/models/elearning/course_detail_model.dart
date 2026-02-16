import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/elearning/session_model.dart';

part 'course_detail_model.freezed.dart';
part 'course_detail_model.g.dart';

@freezed
abstract class CourseDetailModel with _$CourseDetailModel {
  const factory CourseDetailModel({
    required int id,
    required String kode,
    required String nama,
    int? kapasitas,
    String? ruangan,
    String? jadwal,
    required String semester,
    required int mataKuliahId,
    int? dosenId,
    required DateTime createdAt,
    required DateTime updatedAt,
    MataKuliahDetailModel? mataKuliah,
    DosenDetailModel? dosen,
    @Default([]) List<SessionModel> sessions,
    CourseCountModel? count,
  }) = _CourseDetailModel;

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    // Handle _count field
    final countData = json['_count'] as Map<String, dynamic>?;
    final count = countData != null ? CourseCountModel.fromJson(countData) : null;
    
    return CourseDetailModel(
      id: json['id'] as int,
      kode: json['kode'] as String,
      nama: json['nama'] as String,
      kapasitas: json['kapasitas'] as int?,
      ruangan: json['ruangan'] as String?,
      jadwal: json['jadwal'] as String?,
      semester: json['semester'] as String,
      mataKuliahId: json['mataKuliahId'] as int,
      dosenId: json['dosenId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      mataKuliah: json['mataKuliah'] == null
          ? null
          : MataKuliahDetailModel.fromJson(json['mataKuliah'] as Map<String, dynamic>),
      dosen: json['dosen'] == null
          ? null
          : DosenDetailModel.fromJson(json['dosen'] as Map<String, dynamic>),
      sessions: json['sessions'] == null
          ? []
          : (json['sessions'] as List)
              .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      count: count,
    );
  }
}

@freezed
abstract class MataKuliahDetailModel with _$MataKuliahDetailModel {
  const factory MataKuliahDetailModel({
    required int id,
    required String name,
    required String kode,
    required int sks,
    required int semester,
    required String jenisMK,
    String? deskripsi,
    String? silabus,
  }) = _MataKuliahDetailModel;

  factory MataKuliahDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MataKuliahDetailModelFromJson(json);
}

@freezed
abstract class DosenDetailModel with _$DosenDetailModel {
  const factory DosenDetailModel({
    required int id,
    required String name,
    required String nip,
    String? email,
    String? photo,
  }) = _DosenDetailModel;

  factory DosenDetailModel.fromJson(Map<String, dynamic> json) =>
      _$DosenDetailModelFromJson(json);
}

@freezed
abstract class CourseCountModel with _$CourseCountModel {
  const factory CourseCountModel({
    required int krs,
  }) = _CourseCountModel;

  factory CourseCountModel.fromJson(Map<String, dynamic> json) =>
      _$CourseCountModelFromJson(json);
}
