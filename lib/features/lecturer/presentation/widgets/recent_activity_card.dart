import 'package:flutter/material.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/features/lecturer/presentation/lecturer_dashboard_state.dart';
import 'package:jiffy/jiffy.dart';

class RecentActivityCard extends StatelessWidget {
  final ActivityInfo activity;

  const RecentActivityCard({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForType(activity.type);
    final color = _getColorForType(activity.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: BaseColor.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: BaseColor.primaryText.withValues(alpha: 0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  Jiffy.parse(activity.timestamp.toString()).fromNow(),
                  style: TextStyle(
                    fontSize: 11,
                    color: BaseColor.primaryText.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'krs':
        return Icons.assignment_turned_in;
      case 'submission':
        return Icons.upload_file;
      case 'announcement':
        return Icons.campaign;
      case 'presensi':
        return Icons.check_circle;
      case 'quiz':
        return Icons.quiz;
      default:
        return Icons.info;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'krs':
        return Colors.blue;
      case 'submission':
        return Colors.green;
      case 'announcement':
        return Colors.orange;
      case 'presensi':
        return Colors.purple;
      case 'quiz':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
