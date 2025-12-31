import 'package:freezed_annotation/freezed_annotation.dart';

part 'krs_model.freezed.dart';
part 'krs_model.g.dart';

enum StatusKRS {
  @JsonValue('DRAFT')
  DRAFT,
  @JsonValue('DIAJUKAN')
  DIAJUKAN,
  @JsonValue('DISETUJUI')
  DISETUJUI,
  @JsonValue('DITOLAK')
  DITOLAK,
}

@freezed
abstract class KrsModel with _$KrsModel {
  const factory KrsModel({
    required int id,
    required int mahasiswaId,
    required String semester,
    required StatusKRS status,
    required int totalSKS,
    DateTime? tanggalPengajuan,
    DateTime? tanggalPersetujuan,
    String? catatanDosen,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<KelasPerkuliahanModel> kelasPerkuliahan,
  }) = _KrsModel;

  factory KrsModel.fromJson(Map<String, dynamic> json) =>
      _$KrsModelFromJson(json);
}

@freezed
abstract class KelasPerkuliahanModel with _$KelasPerkuliahanModel {
  const factory KelasPerkuliahanModel({
    required int id,
    required String kode,
    required String nama,
    required int tahunAjaran,
    required String semester,
    String? ruangan,
    String? jadwal,
    required int mataKuliahId,
    int? dosenId,
    required DateTime createdAt,
    required DateTime updatedAt,
    MataKuliahModel? mataKuliah,
    DosenModel? dosen,
  }) = _KelasPerkuliahanModel;

  factory KelasPerkuliahanModel.fromJson(Map<String, dynamic> json) =>
      _$KelasPerkuliahanModelFromJson(json);
}

@freezed
abstract class MataKuliahModel with _$MataKuliahModel {
  const factory MataKuliahModel({
    required int id,
    required String name,
    required String kode,
    required int sks,
    required int semester,
    required String jenisMK,
    String? deskripsi,
    required int prodiId,
  }) = _MataKuliahModel;

  factory MataKuliahModel.fromJson(Map<String, dynamic> json) =>
      _$MataKuliahModelFromJson(json);
}

@freezed
abstract class DosenModel with _$DosenModel {
  const factory DosenModel({
    required int id,
    required String name,
    required String nip,
    String? email,
    String? photo,
  }) = _DosenModel;

  factory DosenModel.fromJson(Map<String, dynamic> json) =>
      _$DosenModelFromJson(json);
}

// DTO for adding class to KRS
@freezed
abstract class AddClassDto with _$AddClassDto {
  const factory AddClassDto({
    required int kelasId,
    required String semester,
  }) = _AddClassDto;

  factory AddClassDto.fromJson(Map<String, dynamic> json) =>
      _$AddClassDtoFromJson(json);

  Map<String, dynamic> toJson();
}

// DTO for submitting KRS
@freezed
abstract class SubmitKrsDto with _$SubmitKrsDto {
  const factory SubmitKrsDto({
    required String semester,
  }) = _SubmitKrsDto;

  factory SubmitKrsDto.fromJson(Map<String, dynamic> json) =>
      _$SubmitKrsDtoFromJson(json);

  Map<String, dynamic> toJson();
}
