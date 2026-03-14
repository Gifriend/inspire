import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/network/network.dart';
import 'package:inspire/core/models/schedule/schedule_model.dart';
import 'package:inspire/features/schedule/data/repositories/schedule_repository.dart';

class ScheduleService {
  final ScheduleRepository _repository;

  ScheduleService(this._repository);

  Future<MonthlyScheduleModel> getMonthlySchedule({
    int? year,
    int? month,
  }) async {
    try {
      return await _repository.getMonthlySchedule(year: year, month: month);
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat jadwal');
    }
  }
}

final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return ScheduleService(repository);
});
