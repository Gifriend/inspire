import 'package:flutter/material.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/holiday/holiday_model.dart';
import 'package:inspire/core/models/schedule/schedule_model.dart';
import 'package:inspire/features/schedule/presentation/widgets/schedule_holiday_card.dart';

class ScheduleNoDateSelectedView extends StatelessWidget {
  final MonthlyScheduleModel schedule;
  final VoidCallback onOpenGoogleCalendar;

  const ScheduleNoDateSelectedView({
    super.key,
    required this.schedule,
    required this.onOpenGoogleCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
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
          InkWell(
            onTap: onOpenGoogleCalendar,
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
}

class ScheduleNoDayEventsView extends StatelessWidget {
  final HolidayModel? holiday;

  const ScheduleNoDayEventsView({
    super.key,
    this.holiday,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w24,
                  vertical: BaseSize.h24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (holiday != null) ...[
                      ScheduleHolidayCard(holiday: holiday!),
                      Gap.h20,
                    ],
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
            ),
          ),
        );
      },
    );
  }
}
