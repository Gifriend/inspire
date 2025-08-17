import 'package:flutter/material.dart';
import 'package:inspire/core/constants/constants.dart';

class GetActivitiesRequest {
  final String churchSerial;
  final DateTimeRange? activityDateRange;
  final DateTimeRange? publishDateRange;
  final PresensiType? presensiType;
  final String? activitySerial;

  GetActivitiesRequest({
    required this.churchSerial,
    this.activityDateRange,
    this.publishDateRange,
    this.presensiType,
    this.activitySerial,
  });
}
