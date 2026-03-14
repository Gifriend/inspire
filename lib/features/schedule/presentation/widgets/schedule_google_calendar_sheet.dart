import 'package:flutter/material.dart';
import 'package:inspire/core/constants/constants.dart';

Future<void> showScheduleGoogleCalendarSheet({
  required BuildContext context,
  required String icalUrl,
  required VoidCallback onCopyUrl,
  required VoidCallback onOpenUrl,
}) {
  return showModalBottomSheet(
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
                _ScheduleStep(number: '1', text: 'Buka Google Calendar di browser'),
                _ScheduleStep(
                  number: '2',
                  text: 'Klik ⚙ Settings → Add calendar →\nFrom URL',
                ),
                _ScheduleStep(number: '3', text: 'Paste URL iCal di bawah ini'),
                _ScheduleStep(number: '4', text: 'Klik "Add Calendar" — selesai!'),
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
                  onPressed: onCopyUrl,
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
                onOpenUrl();
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

class _ScheduleStep extends StatelessWidget {
  final String number;
  final String text;

  const _ScheduleStep({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
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
              number,
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
}
