import 'package:flutter/material.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/holiday/holiday_model.dart';
import 'package:inspire/core/models/schedule/schedule_model.dart';
import 'package:inspire/features/schedule/presentation/widgets/schedule_event_card.dart';
import 'package:inspire/features/schedule/presentation/widgets/schedule_holiday_card.dart';

class ScheduleDayEventList extends StatelessWidget {
  final List<ScheduleEventModel> events;
  final DateTime selectedDay;
  final HolidayModel? holiday;
  final ValueChanged<String> onOpenCalendarUrl;

  const ScheduleDayEventList({
    super.key,
    required this.events,
    required this.selectedDay,
    required this.onOpenCalendarUrl,
    this.holiday,
  });

  @override
  Widget build(BuildContext context) {
    final extraItems = holiday != null ? 1 : 0;
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w16,
        vertical: BaseSize.h16,
      ),
      itemCount: events.length + 1 + extraItems,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: BaseSize.h12),
            child: Row(
              children: [
                Text(
                  '${events.first.dayName}, ${_formatDateDisplay(selectedDay)}',
                  style: BaseTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

        if (holiday != null && index == 1) {
          return Padding(
            padding: EdgeInsets.only(bottom: BaseSize.h12),
            child: ScheduleHolidayCard(holiday: holiday!),
          );
        }

        final event = events[index - 1 - extraItems];
        return ScheduleEventCard(
          event: event,
          onOpenCalendar: () => onOpenCalendarUrl(event.googleCalendarUrl),
        );
      },
    );
  }

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
}
