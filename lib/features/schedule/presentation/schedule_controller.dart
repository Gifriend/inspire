import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/holiday/holiday_model.dart';
import 'package:inspire/core/models/schedule/schedule_model.dart';
import 'package:inspire/core/services/schedule_service.dart';
import 'package:inspire/core/services/holiday_service.dart';
import 'package:inspire/features/schedule/presentation/schedule_state.dart';

class ScheduleController extends StateNotifier<ScheduleState> {
  final ScheduleService _scheduleService;
  final HolidayService _holidayService;
  final Map<String, MonthlyScheduleModel> _monthCache = {};
  String? _activeRequestKey;

  ScheduleController(this._scheduleService, this._holidayService)
      : super(ScheduleState.initial()) {
    loadCurrentMonth();
  }

  Future<void> loadCurrentMonth({bool forceRefresh = false}) async {
    final focusedMonth = state.focusedMonth;
    final year = focusedMonth.year;
    final month = focusedMonth.month;
    final requestKey = '$year-$month';
    final cached = forceRefresh ? null : _monthCache[requestKey];

    if (cached != null) {
      state = state.copyWith(
        status: ScheduleStatus.loaded,
        schedule: cached,
        errorMessage: null,
      );
      await _loadHolidays(year);
      return;
    }

    _activeRequestKey = requestKey;

    state = state.copyWith(
      status: ScheduleStatus.loading,
      errorMessage: null,
    );

    try {
      final schedule = await _scheduleService.getMonthlySchedule(
        year: year,
        month: month,
      );
      _monthCache[requestKey] = schedule;

      if (_activeRequestKey != requestKey) {
        return;
      }

      state = state.copyWith(
        status: ScheduleStatus.loaded,
        schedule: schedule,
        errorMessage: null,
      );

      await _loadHolidays(year);
    } catch (e) {
      if (_activeRequestKey != requestKey) {
        return;
      }

      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _loadHolidays(int year) async {
    if (state.loadedHolidayYears.contains(year)) {
      return;
    }

    try {
      final list = await _holidayService.getHolidays(year);
      final holidaysMap = <String, HolidayModel>{
        ...state.holidays,
        for (final holiday in list) holiday.date: holiday,
      };
      final years = <int>{...state.loadedHolidayYears, year};

      state = state.copyWith(
        holidays: holidaysMap,
        loadedHolidayYears: years,
      );
    } catch (_) {
      // Keep screen usable even if holiday source fails.
    }
  }

  Future<void> goToPreviousMonth() async {
    final month = DateTime(state.focusedMonth.year, state.focusedMonth.month - 1);
    state = state.copyWith(focusedMonth: month, selectedDay: null);
    await loadCurrentMonth();
  }

  Future<void> goToNextMonth() async {
    final month = DateTime(state.focusedMonth.year, state.focusedMonth.month + 1);
    state = state.copyWith(focusedMonth: month, selectedDay: null);
    await loadCurrentMonth();
  }

  Future<void> goToToday() async {
    final now = DateTime.now();
    state = state.copyWith(
      focusedMonth: DateTime(now.year, now.month),
      selectedDay: DateTime(now.year, now.month, now.day),
      errorMessage: null,
    );
    await loadCurrentMonth();
  }

  void selectDay(DateTime date) {
    state = state.copyWith(selectedDay: date, errorMessage: null);
  }
}

final scheduleControllerProvider =
    StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
  final scheduleService = ref.watch(scheduleServiceProvider);
  final holidayService = ref.watch(holidayServiceProvider);
  return ScheduleController(scheduleService, holidayService);
});
