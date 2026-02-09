import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_list_model.freezed.dart';
part 'course_list_model.g.dart';

@freezed
abstract class CourseListModel with _$CourseListModel {
  const factory CourseListModel({
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
    MataKuliahInfoModel? mataKuliah,
    DosenInfoModel? dosen,
  }) = _CourseListModel;

  factory CourseListModel.fromJson(Map<String, dynamic> json) =>
      _$CourseListModelFromJson(json);
}

@freezed
abstract class MataKuliahInfoModel with _$MataKuliahInfoModel {
  const factory MataKuliahInfoModel({
    required int id,
    required String name,
    required String kode,
    required int sks,
    required int semester,
    required String jenisMK,
    String? deskripsi,
  }) = _MataKuliahInfoModel;

  factory MataKuliahInfoModel.fromJson(Map<String, dynamic> json) =>
      _$MataKuliahInfoModelFromJson(json);
}

@freezed
abstract class DosenInfoModel with _$DosenInfoModel {
  const factory DosenInfoModel({
    required int id,
    required String name,
    required String nip,
    String? email,
    String? photo,
  }) = _DosenInfoModel;

  factory DosenInfoModel.fromJson(Map<String, dynamic> json) =>
      _$DosenInfoModelFromJson(json);
}
