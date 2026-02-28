import 'package:flutter/material.dart';
import 'package:inspire/core/assets/assets.gen.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/utils.dart';

class ScreenTitleWidget extends StatelessWidget {
  const ScreenTitleWidget.primary({
    super.key,
    required this.title,
    required this.leadIcon,
    required this.leadIconColor,
    required this.onPressedLeadIcon,
    this.subTitle,
  }):
        trailIcon = null,
        trailIconColor = null,
        onPressedTrailIcon = null;

  const ScreenTitleWidget.titleOnly({
    super.key,
    required this.title,
  })  : subTitle = null,
        leadIcon = null,
        leadIconColor = null,
        onPressedLeadIcon = null,
        trailIcon = null,
        trailIconColor = null,
        onPressedTrailIcon = null;

  const ScreenTitleWidget.bottomSheet({
    super.key,
    required this.title,
    required this.trailIcon,
    required this.trailIconColor,
    required this.onPressedTrailIcon,
  })  : subTitle = null,
        leadIcon = null,
        leadIconColor = null,
        onPressedLeadIcon = null;

  final String title;
  final String? subTitle;

  final SvgGenImage? leadIcon;
  final Color? leadIconColor;
  final VoidCallback? onPressedLeadIcon;

  final SvgGenImage? trailIcon;
  final Color? trailIconColor;
  final VoidCallback? onPressedTrailIcon;

  @override
  Widget build(BuildContext context) {
    final iconSize = BaseSize.w24;
    final hasLeadIcon = leadIcon != null;
    final hasTrailIcon = trailIcon != null;

    if (leadIcon == null && trailIcon == null) {
      return Text(
        title,
        style: BaseTypography.headlineLarge,
        textAlign: TextAlign.start,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasLeadIcon) ...[
          buildIcon(
            icon: leadIcon!,
            iconColor: leadIconColor ?? Colors.transparent,
            iconSize: iconSize,
            onPressedIcon: onPressedLeadIcon,
          ),
          Gap.w24,
        ],
        Expanded(
          child: Column(
            crossAxisAlignment:
                hasLeadIcon ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: BaseTypography.headlineSmall,
                textAlign: hasLeadIcon ? TextAlign.center : TextAlign.start,
              ),
              if (subTitle != null)
                Text(
                  subTitle!,
                  textAlign: hasLeadIcon ? TextAlign.center : TextAlign.start,
                  style: BaseTypography.titleMedium,
                ),
            ],
          ),
        ),
        if (hasTrailIcon) ...[
          Gap.w24,
          buildIcon(
            icon: trailIcon!,
            iconColor: trailIconColor ?? Colors.transparent,
            iconSize: iconSize,
            onPressedIcon: onPressedTrailIcon,
          ),
        ],
      ],
    );
  }

  Widget buildIcon({
    required SvgGenImage icon,
    required Color iconColor,
    required VoidCallback? onPressedIcon,
    required double iconSize,
  }) =>
      IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minHeight: iconSize,
          minWidth: iconSize,
        ),
        icon: icon.svg(
          width: iconSize,
          height: iconSize,
          colorFilter: iconColor.filterSrcIn,
        ),
        onPressed: onPressedIcon,
      );
}
