import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/elearning/material_model.dart' as elearning;
import 'package:inspire/core/widgets/widgets.dart';

import '../../../../core/assets/assets.dart';
// Bisa gunakan package url_launcher untuk buka link

class MaterialDetailScreen extends StatelessWidget {
  final elearning.MaterialModel material;

  const MaterialDetailScreen({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: 'Detail Materi',
        leadIcon: Assets.icons.fill.arrowBack,
        onPressedLeadIcon: () => context.pop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(material.title, style: BaseTypography.headlineSmall),
          Gap.h8,
          Chip(
            label: Text(material.type.name),
            backgroundColor: BaseColor.primaryInspire.withValues(alpha: 0.1),
            labelStyle: TextStyle(color: BaseColor.primaryInspire),
          ),
          Gap.h24,
          if (material.type == elearning.MaterialType.text ||
              material.type == elearning.MaterialType.hybrid)
            Text(material.content ?? '', style: BaseTypography.bodyMedium),

          if (material.fileUrl != null) ...[
            Gap.h24,
            ButtonWidget.outlined(
              text: 'Buka File / Link Materi',
              onTap: () {
                // Gunakan url_launcher di sini
                // launchUrl(Uri.parse(material.fileUrl!));
              },
            ),
          ],
        ],
      ),
    );
  }
}
