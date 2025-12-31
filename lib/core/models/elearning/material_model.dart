import 'package:freezed_annotation/freezed_annotation.dart';

part 'material_model.freezed.dart';
part 'material_model.g.dart';

enum MaterialType {
  @JsonValue('TEXT')
  TEXT,
  @JsonValue('FILE')
  FILE,
  @JsonValue('HYBRID')
  HYBRID,
}

@freezed
abstract class MaterialModel with _$MaterialModel {
  const factory MaterialModel({
    required int id,
    required String title,
    required MaterialType type,
    String? content,
    String? fileUrl,
    required int sessionId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MaterialModel;

  factory MaterialModel.fromJson(Map<String, dynamic> json) =>
      _$MaterialModelFromJson(json);
}
