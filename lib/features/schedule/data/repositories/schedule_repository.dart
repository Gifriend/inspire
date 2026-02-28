import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/endpoint/endpoint.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/models/schedule/schedule_model.dart';

class ScheduleRepository {
  final DioClient _dioClient;

  ScheduleRepository(this._dioClient);

  /// Get monthly schedule (works for MAHASISWA and DOSEN).
  /// If [year]/[month] are omitted, backend defaults to current month.
  Future<MonthlyScheduleModel> getMonthlySchedule({
    int? year,
    int? month,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();
      final data = await _dioClient.get(
        Endpoint.scheduleMonthly,
        queryParameters: queryParams,
      );
      return MonthlyScheduleModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get today's schedule only.
  Future<Map<String, dynamic>> getTodaySchedule() async {
    try {
      final data = await _dioClient.get(Endpoint.scheduleToday);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      rethrow;
    }
  }
}

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ScheduleRepository(dioClient);
});
