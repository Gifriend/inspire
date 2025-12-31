import 'package:freezed_annotation/freezed_annotation.dart';

part 'fakultas_model.freezed.dart';
part 'fakultas_model.g.dart';

@freezed
abstract class FakultasModel with _$FakultasModel {
  const factory FakultasModel({
    required int id,
    required String name,
    required String kode,
  }) = _FakultasModel;

  factory FakultasModel.fromJson(Map<String, dynamic> json) =>
      _$FakultasModelFromJson(json);
}
