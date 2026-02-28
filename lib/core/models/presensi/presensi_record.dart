import 'package:freezed_annotation/freezed_annotation.dart';

part 'presensi_record.freezed.dart';
part 'presensi_record.g.dart';

@freezed
abstract class PresensiRecordModel with _$PresensiRecordModel {
  const factory PresensiRecordModel({
    int? id,
    String? status,
    String? method,
    int? sessionId,
    int? mahasiswaId,
    String? createdAt,
  }) = _PresensiRecordModel;

  factory PresensiRecordModel.fromJson(Map<String, dynamic> json) =>
      _$PresensiRecordModelFromJson(json);
}