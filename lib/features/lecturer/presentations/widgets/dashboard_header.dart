import 'package:flutter/material.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/models.dart';
import 'package:inspire/core/utils/extensions/extension.dart';
import 'package:jiffy/jiffy.dart';

class DashboardHeader extends StatelessWidget {
  final UserModel user;

  const DashboardHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w20, vertical: BaseSize.h20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BaseColor.primaryInspire,
            BaseColor.primaryInspire.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(BaseSize.radiusLg),
          bottomRight: Radius.circular(BaseSize.radiusLg),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: BaseSize.radiusLg,
                  backgroundColor: Colors.white,
                  backgroundImage: user.photo != null && user.photo!.isNotEmpty
                      ? NetworkImage(user.photo!)
                      : null,
                  child: user.photo == null || user.photo!.isEmpty
                      ? Text(
                          user.name[0].toUpperCase(),
                          style: BaseTypography.headlineSmall.toBold
                        )
                      : null,
                ),
                Gap.w16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: BaseTypography.bodyLarge.toWhite
                      ),
                      Gap.h4,
                      Text(
                        user.name,
                        style: BaseTypography.titleLarge.toWhite.toBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.nip != null) ...[
                        Gap.h4,
                        Text(
                          'NIP: ${user.nip}',
                          style: BaseTypography.bodySmall.toWhite,
                        ),
                      ],
                      if (user.nim != null) ...[
                        Gap.h4,
                        Text(
                          'NIM: ${user.nim}',
                          style: BaseTypography.bodyLarge.toWhite,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Gap.h12,
            Container(
              padding: EdgeInsets.symmetric(vertical: BaseSize.h8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 16,
                  ),
                  Gap.w8,
                  Text(
                    Jiffy.parse(now.toString()).format(pattern: 'EEEE, dd MMMM yyyy'),
                    style: BaseTypography.bodyMedium.toWhite,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
}
