import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/holiday/holiday_model.dart';
import 'package:inspire/features/schedule/data/repositories/holiday_repository.dart';

class HolidayService {
  final HolidayRepository _repository;

  HolidayService(this._repository);

  Future<List<HolidayModel>> getHolidays(int year) {
    return _repository.getHolidays(year);
  }
}

final holidayServiceProvider = Provider<HolidayService>((ref) {
  final repository = ref.watch(holidayRepositoryProvider);
  return HolidayService(repository);
});