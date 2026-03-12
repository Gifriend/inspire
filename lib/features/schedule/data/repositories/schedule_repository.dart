import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/config/endpoint.dart';
import 'package:inspire/core/data_sources/network/network.dart';
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
      final response = await _dioClient.get<Map<String, dynamic>>(
        Endpoint.scheduleMonthly,
        queryParameters: queryParams,
      );

      if (response == null) {
        throw const ApiException(message: 'Data jadwal kosong');
      }

      return ApiEnvelope.fromDynamic<MonthlyScheduleModel>(
        response,
        dataParser: (data) => MonthlyScheduleModel.fromJson(
          ApiEnvelope.parseSingleMap(data),
        ),
        defaultMessage: 'Gagal memuat jadwal bulanan',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat jadwal bulanan');
    }
  }

  /// Get today's schedule only.
  Future<Map<String, dynamic>> getTodaySchedule() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        Endpoint.scheduleToday,
      );

      if (response == null) {
        return {};
      }

      return ApiEnvelope.fromDynamic<Map<String, dynamic>>(
        response,
        dataParser: (data) {
          if (data is Map<String, dynamic>) {
            return data;
          }
          if (data is List && data.isNotEmpty && data.first is Map) {
            return Map<String, dynamic>.from(data.first as Map);
          }
          return {};
        },
        defaultMessage: 'Gagal memuat jadwal hari ini',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat jadwal hari ini');
    }
  }
}

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ScheduleRepository(dioClient);
});
