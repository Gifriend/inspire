import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/holiday/holiday_model.dart';

/// Calls Nager.Date public API (no auth required).
/// https://date.nager.at/api/v3/PublicHolidays/{year}/ID
class HolidayRepository {
  final Map<int, List<HolidayModel>> _cache = {};

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://date.nager.at',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<HolidayModel>> getHolidays(int year) async {
    final cached = _cache[year];
    if (cached != null) {
      return cached;
    }

    // Start with hardcoded holidays as the base (complete Indonesian holidays
    // including Islamic, Hindu, Buddhist, and Chinese holidays).
    final mergedMap = <String, HolidayModel>{
      for (final h in _hardcodedHolidays(year)) h.date: h,
    };

    // Supplement with API data (may contain holidays not in hardcoded list).
    try {
      final response = await _dio.get('/api/v3/PublicHolidays/$year/ID');
      if (response.statusCode == 200) {
        final list = response.data as List<dynamic>;
        for (final e in list) {
          final holiday =
              HolidayModel.fromJson(e as Map<String, dynamic>);
          // Only add if date not already covered by hardcoded data
          mergedMap.putIfAbsent(holiday.date, () => holiday);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HolidayRepository] API failed for $year: $e');
        debugPrint('[HolidayRepository] Using hardcoded data only.');
      }
    }

    // Sort by date and return
    final result = mergedMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    _cache[year] = result;
    return result;
  }

  /// Hardcoded Indonesian public holidays for offline / API failure fallback.
  /// Fixed holidays (Independence Day, Christmas, etc.) are always correct.
  /// Islamic/Hindu/Buddhist holidays are based on official government decrees.
  List<HolidayModel> _hardcodedHolidays(int year) {
    final Map<int, List<HolidayModel>> data = {
      2025: [
        HolidayModel(date: '2025-01-01', localName: 'Tahun Baru Masehi', name: "New Year's Day"),
        HolidayModel(date: '2025-01-27', localName: 'Isra Miraj Nabi Muhammad SAW', name: 'Isra and Miraj'),
        HolidayModel(date: '2025-01-29', localName: 'Tahun Baru Imlek 2576', name: 'Chinese New Year'),
        HolidayModel(date: '2025-03-29', localName: 'Hari Raya Nyepi 1947', name: 'Saka New Year'),
        HolidayModel(date: '2025-03-31', localName: 'Hari Raya Idul Fitri 1446 H', name: 'Eid al-Fitr'),
        HolidayModel(date: '2025-04-01', localName: 'Hari Raya Idul Fitri 1446 H (Hari 2)', name: 'Eid al-Fitr (day 2)'),
        HolidayModel(date: '2025-04-18', localName: 'Wafat Isa Almasih', name: 'Good Friday'),
        HolidayModel(date: '2025-05-01', localName: 'Hari Buruh Internasional', name: 'International Labour Day'),
        HolidayModel(date: '2025-05-12', localName: 'Hari Raya Waisak 2569', name: 'Vesak Day'),
        HolidayModel(date: '2025-05-29', localName: 'Kenaikan Isa Almasih', name: 'Ascension of Jesus'),
        HolidayModel(date: '2025-06-01', localName: 'Hari Lahir Pancasila', name: 'Pancasila Day'),
        HolidayModel(date: '2025-06-07', localName: 'Hari Raya Idul Adha 1446 H', name: 'Eid al-Adha'),
        HolidayModel(date: '2025-06-27', localName: 'Tahun Baru Islam 1447 H', name: 'Islamic New Year'),
        HolidayModel(date: '2025-08-17', localName: 'Hari Kemerdekaan Republik Indonesia', name: 'Independence Day'),
        HolidayModel(date: '2025-09-05', localName: 'Maulid Nabi Muhammad SAW', name: "Prophet's Birthday"),
        HolidayModel(date: '2025-12-25', localName: 'Hari Raya Natal', name: 'Christmas Day'),
        HolidayModel(date: '2025-12-26', localName: 'Hari Raya Natal (Hari 2)', name: 'Christmas Day (day 2)'),
      ],
      2026: [
        HolidayModel(date: '2026-01-01', localName: 'Tahun Baru Masehi', name: "New Year's Day"),
        HolidayModel(date: '2026-01-17', localName: 'Isra Miraj Nabi Muhammad SAW', name: 'Isra and Miraj'),
        HolidayModel(date: '2026-02-17', localName: 'Tahun Baru Imlek 2577', name: 'Chinese New Year'),
        HolidayModel(date: '2026-03-19', localName: 'Hari Raya Nyepi 1948', name: 'Saka New Year'),
        HolidayModel(date: '2026-03-20', localName: 'Wafat Isa Almasih', name: 'Good Friday'),
        HolidayModel(date: '2026-03-20', localName: 'Hari Raya Idul Fitri 1447 H', name: 'Eid al-Fitr'),
        HolidayModel(date: '2026-03-21', localName: 'Hari Raya Idul Fitri 1447 H (Hari 2)', name: 'Eid al-Fitr (day 2)'),
        HolidayModel(date: '2026-05-01', localName: 'Hari Buruh Internasional', name: 'International Labour Day'),
        HolidayModel(date: '2026-05-14', localName: 'Kenaikan Isa Almasih', name: 'Ascension of Jesus'),
        HolidayModel(date: '2026-05-31', localName: 'Hari Raya Waisak 2570', name: 'Vesak Day'),
        HolidayModel(date: '2026-06-01', localName: 'Hari Lahir Pancasila', name: 'Pancasila Day'),
        HolidayModel(date: '2026-05-27', localName: 'Hari Raya Idul Adha 1447 H', name: 'Eid al-Adha'),
        HolidayModel(date: '2026-06-16', localName: 'Tahun Baru Islam 1448 H', name: 'Islamic New Year'),
        HolidayModel(date: '2026-08-17', localName: 'Hari Kemerdekaan Republik Indonesia', name: 'Independence Day'),
        HolidayModel(date: '2026-08-25', localName: 'Maulid Nabi Muhammad SAW', name: "Prophet's Birthday"),
        HolidayModel(date: '2026-12-25', localName: 'Hari Raya Natal', name: 'Christmas Day'),
      ],
    };
    return data[year] ?? [];
  }
}

final holidayRepositoryProvider = Provider<HolidayRepository>(
  (_) => HolidayRepository(),
);

/// AutoDispose so it re-fetches each time screen is opened fresh.
final holidayProvider =
    FutureProvider.autoDispose.family<List<HolidayModel>, int>((ref, year) {
  return ref.watch(holidayRepositoryProvider).getHolidays(year);
});
