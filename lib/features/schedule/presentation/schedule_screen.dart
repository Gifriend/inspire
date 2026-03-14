import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/holiday/holiday_model.dart';
import 'package:inspire/core/models/schedule/schedule_model.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;
  Map<String, HolidayModel> _holidays = {};
  final Set<int> _loadedHolidayYears = {};
  String? _lastGroupedEventsKey;
  Map<String, List<ScheduleEventModel>> _groupedEventsCache = const {};

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonth();
    });
  }

  void _loadMonth() {
    ref
        .read(scheduleControllerProvider.notifier)
        .loadSchedule(year: _focusedMonth.year, month: _focusedMonth.month);
    _loadHolidays(_focusedMonth.year);
  }

  void _loadHolidays(int year) {
    if (_loadedHolidayYears.contains(year)) {
      return;
    }

    // Call repository directly to avoid FutureProvider caching empty results
    ref.read(holidayRepositoryProvider).getHolidays(year).then((list) {
      if (mounted) {
        setState(() {
          _loadedHolidayYears.add(year);
          _holidays = {for (final h in list) h.date: h};
        });
      }
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      _selectedDay = null;
    });
    _loadMonth();
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      _selectedDay = null;
    });
    _loadMonth();
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _focusedMonth = now;
      _selectedDay = now;
    });
    _loadMonth();
  }

  /// Group events by date string "yyyy-MM-dd"
  Map<String, List<ScheduleEventModel>> _groupEvents(
    List<ScheduleEventModel> events,
  ) {
    final map = <String, List<ScheduleEventModel>>{};
    for (final e in events) {
      map.putIfAbsent(e.date, () => []).add(e);
    }
    return map;
  }

  Map<String, List<ScheduleEventModel>> _groupEventsCached(
    MonthlyScheduleModel schedule,
  ) {
    final cacheKey =
        '${schedule.year}-${schedule.month}-${schedule.totalEvents}-${schedule.events.length}';
    if (_lastGroupedEventsKey == cacheKey) {
      return _groupedEventsCache;
    }

    final grouped = _groupEvents(schedule.events);
    _lastGroupedEventsKey = cacheKey;
    _groupedEventsCache = grouped;
    return grouped;
  }

  String _monthLabel(DateTime value) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[value.month]} ${value.year}';
  }

  String _dateKey(DateTime d) {
    final y = d.year.toString();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleControllerProvider);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'Jadwal Kuliah',
        leadIcon: Assets.icons.fill.arrowBack,
        onPressedLeadIcon: () => context.pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: BaseColor.white),
            onPressed: _goToToday,
            tooltip: 'Hari Ini',
          ),
          // show Google Calendar action only when schedule is loaded
          scheduleState.maybeWhen(
            loaded: (schedule) => IconButton(
              icon: Icon(Icons.calendar_month, color: BaseColor.white),
              onPressed: () => _showGoogleCalendarOptions(schedule.icalUrl),
              tooltip: 'Google Calendar',
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      loading: scheduleState.maybeWhen(
        loading: () => true,
        orElse: () => false,
      ),
      child: scheduleState.when(
        initial: () => const Center(child: Text('Memuat jadwal...')),
        loading: () => const SizedBox.shrink(),
        loaded: (schedule) => _buildContent(schedule),
        error: (message) => _buildError(message),
      ),
    );
  }

  Widget _buildContent(MonthlyScheduleModel schedule) {
    final eventsByDate = _groupEventsCached(schedule);
    final eventsForSelectedDay = _selectedDay != null
        ? eventsByDate[_dateKey(_selectedDay!)] ?? []
        : <ScheduleEventModel>[];
    final selectedHoliday = _selectedDay != null
        ? _holidays[_dateKey(_selectedDay!)]
        : null;

    return Column(
      children: [
        // Month header + Calendar grid
        _buildCalendarSection(schedule, eventsByDate, _holidays),

        // Divider
        Container(height: 1, color: Colors.grey.shade200),

        // Event list for selected day
        Expanded(
          child: _selectedDay == null
              ? _buildNoDateSelected(schedule)
              : eventsForSelectedDay.isEmpty
              ? _buildNoDayEvents(holiday: selectedHoliday)
              : _buildDayEventList(
                  eventsForSelectedDay,
                  holiday: selectedHoliday,
                ),
        ),
      ],
    );
  }

  // ─── CALENDAR SECTION ────────────────────────────────────────────

  Widget _buildCalendarSection(
    MonthlyScheduleModel schedule,
    Map<String, List<ScheduleEventModel>> eventsByDate,
    Map<String, HolidayModel> holidays,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Month navigator
          _buildMonthNavigator(schedule),
          // Day-of-week header
          _buildWeekdayHeader(),
          // Date grid
          _buildDateGrid(eventsByDate, holidays),
          Gap.h6,
          // Legend
          _buildCalendarLegend(holidays),
          Gap.h8,
        ],
      ),
    );
  }

  Widget _buildCalendarLegend(Map<String, HolidayModel> holidays) {
    // Count holidays in this month
    final monthHolidays = holidays.values.where((h) {
      return h.date.startsWith(
        '${_focusedMonth.year}-${_focusedMonth.month.toString().padLeft(2, '0')}',
      );
    }).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
      child: Row(
        children: [
          _legendDot(BaseColor.primaryInspire),
          const SizedBox(width: 4),
          Text(
            'Kelas',
            style: BaseTypography.bodySmall.copyWith(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          _legendDot(Colors.red.shade400),
          const SizedBox(width: 4),
          Text(
            'Hari Libur Nasional',
            style: BaseTypography.bodySmall.copyWith(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
          if (monthHolidays.isNotEmpty) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                '${monthHolidays.length} libur bulan ini',
                style: BaseTypography.bodySmall.copyWith(
                  fontSize: 10,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildMonthNavigator(MonthlyScheduleModel schedule) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w16,
        vertical: BaseSize.h12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _goToPreviousMonth,
            color: BaseColor.primaryInspire,
          ),
          Column(
            children: [
              Text(
                _monthLabel(_focusedMonth),
                style: BaseTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Gap.h4,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: schedule.role == 'MAHASISWA'
                      ? Colors.blue.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  schedule.role == 'MAHASISWA' ? 'Mahasiswa' : 'Dosen',
                  style: BaseTypography.bodySmall.copyWith(
                    color: schedule.role == 'MAHASISWA'
                        ? Colors.blue.shade700
                        : Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _goToNextMonth,
            color: BaseColor.primaryInspire,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w8),
      child: Row(
        children: days.map((d) {
          final isWeekend = d == 'Sab' || d == 'Min';
          return Expanded(
            child: Center(
              child: Text(
                d,
                style: BaseTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isWeekend ? Colors.red.shade400 : Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateGrid(
    Map<String, List<ScheduleEventModel>> eventsByDate,
    Map<String, HolidayModel> holidays,
  ) {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;

    // Monday=1 in DateTime.weekday → 0-indexed from Mon
    int startWeekday = firstDayOfMonth.weekday - 1;
    final today = DateTime.now();
    final cells = <Widget>[];

    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final key = _dateKey(date);
      final hasEvents = eventsByDate.containsKey(key);
      final eventCount = eventsByDate[key]?.length ?? 0;
      final holiday = holidays[key];
      final isHoliday = holiday != null;
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isSelected =
          _selectedDay != null &&
          date.year == _selectedDay!.year &&
          date.month == _selectedDay!.month &&
          date.day == _selectedDay!.day;
      final isWeekend = date.weekday == 6 || date.weekday == 7;

      // Background priority: selected > holiday > today
      Color? bgColor;
      if (isSelected) {
        bgColor = BaseColor.primaryInspire;
      } else if (isHoliday) {
        bgColor = Colors.red.shade50;
      } else if (isToday) {
        bgColor = BaseColor.primaryInspire.withValues(alpha: 0.1);
      }

      cells.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (_selectedDay == date) return;
              setState(() => _selectedDay = date);
            },
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? null
                    : isHoliday
                    ? Border.all(color: Colors.red.shade200, width: 1)
                    : isToday
                    ? Border.all(color: BaseColor.primaryInspire, width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isToday || isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : isHoliday || isWeekend
                          ? Colors.red.shade500
                          : Colors.black87,
                    ),
                  ),
                  if (hasEvents || isHoliday) ...[
                    Gap.h4,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasEvents)
                          ...List.generate(
                            eventCount.clamp(0, 2),
                            (i) => Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.white
                                    : BaseColor.primaryInspire,
                              ),
                            ),
                          ),
                        if (isHoliday)
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.red.shade400,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Calculate rows needed
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final gridHeight = rows * 52.0;

    return SizedBox(
      height: gridHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSize.w8),
        child: GridView.count(
          crossAxisCount: 7,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.0,
          children: cells,
        ),
      ),
    );
  }

  // ─── EVENT LIST SECTION ──────────────────────────────────────────

  Widget _buildNoDateSelected(MonthlyScheduleModel schedule) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(BaseSize.w16),
      child: Column(
        children: [
          Gap.h16,
          Icon(Icons.touch_app, size: 48, color: Colors.grey.shade300),
          Gap.h12,
          Text(
            'Pilih tanggal untuk melihat jadwal',
            style: BaseTypography.bodyMedium.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          Gap.h24,
          // Summary card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(BaseSize.w16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  BaseColor.primaryInspire,
                  BaseColor.primaryInspire.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
            ),
            child: Column(
              children: [
                Text(
                  '${schedule.totalEvents}',
                  style: BaseTypography.headlineLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Gap.h4,
                Text(
                  'Total pertemuan bulan ini',
                  style: BaseTypography.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Gap.h16,
          // iCal subscription hint
          InkWell(
            onTap: () => _showGoogleCalendarOptions(schedule.icalUrl),
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(BaseSize.w16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                  ),
                  Gap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sinkronkan ke Google Calendar',
                          style: BaseTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap.h4,
                        Text(
                          'Subscribe otomatis via iCal URL',
                          style: BaseTypography.bodySmall.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDayEvents({HolidayModel? holiday}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSize.w24, vertical: BaseSize.h24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (holiday != null) ...[_buildHolidayCard(holiday), Gap.h20],
            Icon(Icons.event_available, size: 48, color: Colors.grey.shade300),
            Gap.h12,
            Text(
              holiday != null
                  ? 'Tidak ada jadwal kuliah di hari libur ini'
                  : 'Tidak ada jadwal di tanggal ini',
              style: BaseTypography.bodyMedium.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayEventList(
    List<ScheduleEventModel> events, {
    HolidayModel? holiday,
  }) {
    final extraItems = holiday != null ? 1 : 0;
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w16,
        vertical: BaseSize.h16,
      ),
      itemCount:
          events.length + 1 + extraItems, // header + optional holiday + events
      itemBuilder: (context, index) {
        // Header row (date + kelas count)
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: BaseSize.h12),
            child: Row(
              children: [
                Text(
                  '${events.first.dayName}, ${_formatDateDisplay(_selectedDay!)}',
                  style: BaseTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: BaseColor.primaryInspire.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${events.length} kelas',
                    style: BaseTypography.bodySmall.copyWith(
                      color: BaseColor.primaryInspire,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        // Holiday banner (index 1 when holiday exists)
        if (holiday != null && index == 1) {
          return Padding(
            padding: EdgeInsets.only(bottom: BaseSize.h12),
            child: _buildHolidayCard(holiday),
          );
        }
        final event = events[index - 1 - extraItems];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(ScheduleEventModel event) {
    return Container(
      height: BaseSize.customHeight(175),
      width: double.infinity,
      margin: EdgeInsets.only(bottom: BaseSize.h12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: BaseColor.primaryInspire,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(BaseSize.radiusMd),
                bottomLeft: Radius.circular(BaseSize.radiusMd),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time row
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: BaseColor.primaryInspire,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.startTime} - ${event.endTime}',
                        style: BaseTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BaseColor.primaryInspire,
                        ),
                      ),
                    ],
                  ),
                  Gap.h8,
                  // Mata kuliah name
                  Text(
                    event.mataKuliah,
                    style: BaseTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap.h4,
                  // Kode MK & Kelas
                  Text(
                    '${event.kodeMK} — ${event.kelas}',
                    style: BaseTypography.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Gap.h8,
                  // Dosen
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.dosenNama,
                          style: BaseTypography.bodySmall.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Gap.h4,
                  // Ruangan
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.ruangan ?? 'Ruangan belum ditentukan',
                          style: BaseTypography.bodySmall.copyWith(
                            color: event.ruangan != null
                                ? Colors.grey.shade600
                                : Colors.orange.shade600,
                            fontStyle: event.ruangan == null
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Gap.h8,
                  // Google Calendar button
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => _launchUrl(event.googleCalendarUrl),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              size: 14,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Google Calendar',
                              style: BaseTypography.bodySmall.copyWith(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────

  String _formatDateDisplay(DateTime d) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  void _showGoogleCalendarOptions(String icalUrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Sinkronkan ke Google Calendar',
              style: BaseTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap.h16,
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(BaseSize.w16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Langkah-langkah:',
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h8,
                  _buildStep('1', 'Buka Google Calendar di browser'),
                  _buildStep('2', 'Klik ⚙ Settings → Add calendar →\nFrom URL'),
                  _buildStep('3', 'Paste URL iCal di bawah ini'),
                  _buildStep('4', 'Klik "Add Calendar" — selesai!'),
                ],
              ),
            ),
            Gap.h16,
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(BaseSize.w12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      icalUrl,
                      style: BaseTypography.bodySmall.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      // Copy to clipboard
                      _copyToClipboard(icalUrl);
                    },
                    tooltip: 'Salin URL',
                  ),
                ],
              ),
            ),
            Gap.h16,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _launchUrl(icalUrl);
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Buka iCal URL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BaseColor.primaryInspire,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  ),
                ),
              ),
            ),
            Gap.h16,
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BaseColor.primaryInspire,
              shape: BoxShape.circle,
            ),
            child: Text(
              num,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: BaseTypography.bodySmall)),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL berhasil disalin'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildHolidayCard(HolidayModel holiday) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w16,
        vertical: BaseSize.h12,
      ),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.celebration,
              color: Colors.red.shade600,
              size: 20,
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hari Libur Nasional',
                  style: BaseTypography.bodySmall.copyWith(
                    color: Colors.red.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap.h4,
                Text(
                  holiday.localName,
                  style: BaseTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Gagal memuat jadwal', style: BaseTypography.titleMedium),
          Gap.h8,
          Text(
            message,
            style: BaseTypography.bodyMedium.copyWith(color: BaseColor.red),
            textAlign: TextAlign.center,
          ),
          Gap.h16,
          ElevatedButton(onPressed: _loadMonth, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
