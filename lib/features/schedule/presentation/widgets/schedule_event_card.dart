import 'package:flutter/material.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/schedule/schedule_model.dart';

class ScheduleEventCard extends StatelessWidget {
  final ScheduleEventModel event;
  final VoidCallback onOpenCalendar;

  const ScheduleEventCard({
    super.key,
    required this.event,
    required this.onOpenCalendar,
  });

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    event.mataKuliah,
                    style: BaseTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap.h4,
                  Text(
                    '${event.kodeMK} — ${event.kelas}',
                    style: BaseTypography.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Gap.h8,
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: onOpenCalendar,
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
}
