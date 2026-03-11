import 'package:flutter/material.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/presensi_overview.dart';
import 'package:inspire/core/widgets/widgets.dart';

class PresensiByYouWidget extends StatelessWidget {
  const PresensiByYouWidget({
    super.key,
    required this.onPressedViewAll,
    required this.data,
    required this.onPressedCard,
  });

  final VoidCallback onPressedViewAll;
  final void Function(PresensiOverview presensiOverview) onPressedCard;
  final List<PresensiOverview> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentTitleWidget(
          onPressedViewAll: onPressedViewAll,
          count: data.length,
          title: 'Publish By You',
        ),
        Gap.h12,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => Gap.h6,
          itemCount: data.length,
          itemBuilder: (context, index) {
            final presensi = data[index];
            return CardOverviewListItemWidget(
              title: presensi.title,
              type: presensi.type,
              onPressedCard: () => onPressedCard(presensi),
            );
          },
        ),
        Gap.h6,
      ],
    );
  }
}
