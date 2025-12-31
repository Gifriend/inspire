import 'package:freezed_annotation/freezed_annotation.dart';

part 'announcement_model.freezed.dart';
part 'announcement_model.g.dart';

@freezed
abstract class AnnouncementModel with _$AnnouncementModel {
  const factory AnnouncementModel({
    required int id,
    required String judul,
    required String isi,
    required String kategori,
    required int dosenId,
    required bool aktif,
    required bool isGlobal,
    required DateTime createdAt,
    DateTime? updatedAt,
    DosenInfoModel? dosen,
    List<KelasTagModel>? kelas,
  }) = _AnnouncementModel;

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementModelFromJson(json);
}

@freezed
abstract class DosenInfoModel with _$DosenInfoModel {
  const factory DosenInfoModel({
    required String name,
    String? nip,
  }) = _DosenInfoModel;

  factory DosenInfoModel.fromJson(Map<String, dynamic> json) =>
      _$DosenInfoModelFromJson(json);
}

@freezed
abstract class KelasTagModel with _$KelasTagModel {
  const factory KelasTagModel({
    required String nama,
    required String kode,
  }) = _KelasTagModel;

  factory KelasTagModel.fromJson(Map<String, dynamic> json) =>
      _$KelasTagModelFromJson(json);
}
