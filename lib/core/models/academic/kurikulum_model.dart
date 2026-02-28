import 'package:freezed_annotation/freezed_annotation.dart';

part 'kurikulum_model.freezed.dart';
part 'kurikulum_model.g.dart';

enum StatusMataKuliah {
  @JsonValue('AKTIF')
  aktif,
  @JsonValue('NON_AKTIF')
  nonAktif,
}

@freezed
abstract class KurikulumModel with _$KurikulumModel {
  const factory KurikulumModel({
    required int id,
    required String name,
    required int tahun,
    @Default(StatusMataKuliah.aktif) StatusMataKuliah status,
    required int prodiId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _KurikulumModel;

  factory KurikulumModel.fromJson(Map<String, dynamic> json) =>
      _$KurikulumModelFromJson(json);
}
