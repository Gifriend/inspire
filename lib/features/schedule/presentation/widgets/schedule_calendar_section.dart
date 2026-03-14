import 'package:flutter/material.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/holiday/holiday_model.dart';
import 'package:inspire/core/models/schedule/schedule_model.dart';

class ScheduleCalendarSection extends StatelessWidget {
  final MonthlyScheduleModel schedule;
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final Map<String, List<ScheduleEventModel>> eventsByDate;
  final Map<String, HolidayModel> holidays;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDay;

  const ScheduleCalendarSection({
    super.key,
    required this.schedule,
    required this.focusedMonth,
    required this.selectedDay,
    required this.eventsByDate,
    required this.holidays,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildMonthNavigator(),
          _buildWeekdayHeader(),
          _buildDateGrid(),
          Gap.h6,
          _buildCalendarLegend(),
          Gap.h8,
        ],
      ),
    );
  }

  Widget _buildMonthNavigator() {
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
            onPressed: onPreviousMonth,
            color: BaseColor.primaryInspire,
          ),
          Column(
            children: [
              Text(
                _monthLabel(focusedMonth),
                style: BaseTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Gap.h4,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
            onPressed: onNextMonth,
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

  Widget _buildDateGrid() {
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;

    final startWeekday = firstDayOfMonth.weekday - 1;
    final today = DateTime.now();
    final cells = <Widget>[];

    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, day);
      final key = _dateKey(date);
      final hasEvents = eventsByDate.containsKey(key);
      final eventCount = eventsByDate[key]?.length ?? 0;
      final holiday = holidays[key];
      final isHoliday = holiday != null;
      final isToday =
          date.year == today.year && date.month == today.month && date.day == today.day;
      final isSelected = selectedDay != null &&
          date.year == selectedDay!.year &&
          date.month == selectedDay!.month &&
          date.day == selectedDay!.day;
      final isWeekend = date.weekday == 6 || date.weekday == 7;

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
              if (selectedDay == date) return;
              onSelectDay(date);
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
                      fontWeight:
                          isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
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
                                color: isSelected ? Colors.white : BaseColor.primaryInspire,
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
                              color: isSelected ? Colors.white : Colors.red.shade400,
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

  Widget _buildCalendarLegend() {
    final monthHolidays = holidays.values.where((h) {
      return h.date.startsWith(
        '${focusedMonth.year}-${focusedMonth.month.toString().padLeft(2, '0')}',
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
}
