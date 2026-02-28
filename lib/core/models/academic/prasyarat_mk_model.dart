import 'package:freezed_annotation/freezed_annotation.dart';

part 'prasyarat_mk_model.freezed.dart';
part 'prasyarat_mk_model.g.dart';

@freezed
abstract class PrasyaratMkModel with _$PrasyaratMkModel {
  const factory PrasyaratMkModel({
    required int id,
    required int mataKuliahId,
    required int mataKuliahPrasyaratId,
  }) = _PrasyaratMkModel;

  factory PrasyaratMkModel.fromJson(Map<String, dynamic> json) =>
      _$PrasyaratMkModelFromJson(json);
}
