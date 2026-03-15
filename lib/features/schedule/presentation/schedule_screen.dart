import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/schedule/schedule_model.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'package:inspire/features/schedule/presentation/widgets/schedule_calendar_section.dart';
import 'package:inspire/features/schedule/presentation/widgets/schedule_day_event_list.dart';
import 'package:inspire/features/schedule/presentation/widgets/schedule_empty_states.dart';
import 'package:inspire/features/schedule/presentation/widgets/schedule_google_calendar_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  String? _lastGroupedEventsKey;
  Map<String, List<ScheduleEventModel>> _groupedEventsCache = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scheduleControllerProvider.notifier).loadCurrentMonth();
    });
  }

  Future<void> _refreshMonth() async {
    await ref.read(scheduleControllerProvider.notifier).refreshCurrentMonth();
  }

  void _goToPreviousMonth() {
    ref.read(scheduleControllerProvider.notifier).goToPreviousMonth();
  }

  void _goToNextMonth() {
    ref.read(scheduleControllerProvider.notifier).goToNextMonth();
  }

  void _goToToday() {
    ref.read(scheduleControllerProvider.notifier).goToToday();
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

  void _showGoogleCalendarOptions(String icalUrl) {
    showScheduleGoogleCalendarSheet(
      context: context,
      icalUrl: icalUrl,
      onCopyUrl: () => _copyToClipboard(icalUrl),
      onOpenUrl: () => _launchUrl(icalUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(scheduleControllerProvider.notifier);
    final scheduleState = ref.watch(scheduleControllerProvider);
    final schedule = scheduleState.schedule;
    final isBlockingLoading =
        scheduleState.status == ScheduleStatus.loading && schedule == null;

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
          if (schedule != null)
            IconButton(
              icon: Icon(Icons.calendar_month, color: BaseColor.white),
              onPressed: () => _showGoogleCalendarOptions(schedule.icalUrl),
              tooltip: 'Google Calendar',
            ),
        ],
      ),
      loading: isBlockingLoading,
      child: _buildBody(scheduleState, schedule, controller),
    );
  }

  Widget _buildBody(
    ScheduleState state,
    MonthlyScheduleModel? schedule,
    ScheduleController controller,
  ) {
    return switch (state.status) {
      ScheduleStatus.loaded when schedule != null => _buildContent(
        schedule,
        state,
        controller,
      ),

      ScheduleStatus.loading =>
        schedule != null
            ? _buildContent(schedule, state, controller)
            : _buildRefreshContainer(
                const Center(child: Text('Memuat jadwal...')),
              ),

      ScheduleStatus.error => _buildRefreshContainer(
        _buildError(state.errorMessage ?? 'Gagal memuat jadwal'),
      ),

      ScheduleStatus.initial || _ =>
        schedule != null
            ? _buildContent(schedule, state, controller)
            : _buildRefreshContainer(
                const Center(child: Text('Tarik ke bawah untuk memuat jadwal')),
              ),
    };
  }

  Widget _buildContent(
    MonthlyScheduleModel schedule,
    ScheduleState state,
    ScheduleController controller,
  ) {
    final eventsByDate = _groupEventsCached(schedule);
    final selectedDay = state.selectedDay;
    final eventsForSelectedDay = selectedDay != null
        ? eventsByDate[_dateKey(selectedDay)] ?? []
        : <ScheduleEventModel>[];
    final selectedHoliday = selectedDay != null
        ? state.holidays[_dateKey(selectedDay)]
        : null;

    return Column(
      children: [
        ScheduleCalendarSection(
          schedule: schedule,
          focusedMonth: state.focusedMonth,
          selectedDay: state.selectedDay,
          eventsByDate: eventsByDate,
          holidays: state.holidays,
          onPreviousMonth: _goToPreviousMonth,
          onNextMonth: _goToNextMonth,
          onSelectDay: controller.selectDay,
        ),

        Container(height: 1, color: Colors.grey.shade200),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshMonth,
            child: selectedDay == null
                ? ScheduleNoDateSelectedView(
                    schedule: schedule,
                    onOpenGoogleCalendar: () =>
                        _showGoogleCalendarOptions(schedule.icalUrl),
                  )
                : eventsForSelectedDay.isEmpty
                ? ScheduleNoDayEventsView(holiday: selectedHoliday)
                : ScheduleDayEventList(
                    events: eventsForSelectedDay,
                    selectedDay: selectedDay,
                    holiday: selectedHoliday,
                    onOpenCalendarUrl: _launchUrl,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshContainer(Widget child) {
    return RefreshIndicator(
      onRefresh: _refreshMonth,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: child,
          ),
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
          ElevatedButton(
            onPressed: () => _refreshMonth(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
