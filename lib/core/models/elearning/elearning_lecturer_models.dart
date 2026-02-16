import 'package:freezed_annotation/freezed_annotation.dart';

part 'elearning_lecturer_models.freezed.dart';
part 'elearning_lecturer_models.g.dart';

@freezed
abstract class StudentInfoModel with _$StudentInfoModel {
  const factory StudentInfoModel({
    required int id,
    required String nim,
    required String name,
    String? email,
    String? photo,
  }) = _StudentInfoModel;

  factory StudentInfoModel.fromJson(Map<String, dynamic> json) =>
      _$StudentInfoModelFromJson(json);
}
