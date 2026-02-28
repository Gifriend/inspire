import 'package:freezed_annotation/freezed_annotation.dart';

part 'elearning_class_config_model.freezed.dart';
part 'elearning_class_config_model.g.dart';

enum ElearningSetupMode {
  @JsonValue('NEW')
  newClass,
  @JsonValue('EXISTING')
  existing,
}

enum ElearningEntityType {
  @JsonValue('MATERIAL')
  material,
  @JsonValue('ASSIGNMENT')
  assignment,
  @JsonValue('QUIZ')
  quiz,
}

@freezed
abstract class ElearningClassConfigModel with _$ElearningClassConfigModel {
  const factory ElearningClassConfigModel({
    required int id,
    required int kelasPerkuliahanId,
    @Default(ElearningSetupMode.newClass) ElearningSetupMode setupMode,
    int? sourceKelasPerkuliahanId,
    @Default(false) bool isMergedClass,
    required int createdByDosenId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ElearningClassConfigModel;

  factory ElearningClassConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ElearningClassConfigModelFromJson(json);
}
