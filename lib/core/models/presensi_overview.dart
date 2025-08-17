import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/constants/constants.dart';

part 'presensi_overview.freezed.dart';
part 'presensi_overview.g.dart';

@freezed
abstract class PresensiOverview with _$PresensiOverview {
  const factory PresensiOverview({
    required String serial,
    required String title,
    required PresensiType type,
  }) = _PresensiOverview;

  factory PresensiOverview.fromJson(Map<String, dynamic> data) =>
      _$PresensiOverviewFromJson(data);
}
