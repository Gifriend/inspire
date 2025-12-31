import 'package:freezed_annotation/freezed_annotation.dart';

part 'prodi_model.freezed.dart';
part 'prodi_model.g.dart';

@freezed
abstract class ProdiModel with _$ProdiModel {
  const factory ProdiModel({
    required int id,
    required String name,
    required String kode,
    required String jenjang,
  }) = _ProdiModel;

  factory ProdiModel.fromJson(Map<String, dynamic> json) =>
      _$ProdiModelFromJson(json);
}
