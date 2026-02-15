import 'package:freezed_annotation/freezed_annotation.dart';
import '../../constants/constants.dart';
export '../../constants/enums/enums.dart' show MaterialType;

part 'material_model.freezed.dart';
part 'material_model.g.dart';

@freezed
abstract class MaterialModel with _$MaterialModel {
  const factory MaterialModel({
    required String id,
    required String title,
    required MaterialType type,
    String? content,
    String? fileUrl,
    required String sessionId,
    required DateTime createdAt,
  }) = _MaterialModel;

  factory MaterialModel.fromJson(Map<String, dynamic> json) =>
      _$MaterialModelFromJson(json);
}
