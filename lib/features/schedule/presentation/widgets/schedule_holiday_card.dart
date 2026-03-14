import 'package:flutter/material.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/holiday/holiday_model.dart';

class ScheduleHolidayCard extends StatelessWidget {
  final HolidayModel holiday;

  const ScheduleHolidayCard({
    super.key,
    required this.holiday,
  });

  @override
  Widget build(BuildContext context) {
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
}
