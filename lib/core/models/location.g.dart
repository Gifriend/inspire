// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Location _$LocationFromJson(Map<String, dynamic> json) => _Location(
  latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
  longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
  name: json['name'] as String? ?? "",
);

Map<String, dynamic> _$LocationToJson(_Location instance) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'name': instance.name,
};
