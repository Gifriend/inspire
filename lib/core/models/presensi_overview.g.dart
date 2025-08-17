// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presensi_overview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PresensiOverview _$PresensiOverviewFromJson(Map<String, dynamic> json) =>
    _PresensiOverview(
      serial: json['serial'] as String,
      title: json['title'] as String,
      type: $enumDecode(_$PresensiTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$PresensiOverviewToJson(_PresensiOverview instance) =>
    <String, dynamic>{
      'serial': instance.serial,
      'title': instance.title,
      'type': _$PresensiTypeEnumMap[instance.type]!,
    };

const _$PresensiTypeEnumMap = {
  PresensiType.kelas: 'KELAS',
  PresensiType.uas: 'UAS',
  PresensiType.event: 'EVENT',
};
