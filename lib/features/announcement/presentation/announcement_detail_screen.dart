import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'package:jiffy/jiffy.dart';

class AnnouncementDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const AnnouncementDetailScreen({super.key, required this.id});

  @override
  ConsumerState<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState
    extends ConsumerState<AnnouncementDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final announcementId = int.tryParse(widget.id);
      if (announcementId != null) {
        ref
            .read(announcementDetailControllerProvider(announcementId).notifier)
            .loadAnnouncementDetail();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final announcementId = int.tryParse(widget.id);

    if (announcementId == null) {
      return Scaffold(
        appBar: AppBarWidget(
          leadIcon: Assets.icons.fill.arrowBack,
          leadIconColor: BaseColor.white,
          onPressedLeadIcon: () => context.pop(),
          title: 'Detail Pengumuman',
        ),
        body: const Center(child: Text('Invalid announcement ID')),
      );
    }

    final detailState = ref.watch(
      announcementDetailControllerProvider(announcementId),
    );

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: 'Detail Pengumuman',
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
      ),
      loading: detailState.maybeWhen(loading: () => true, orElse: () => false),
      child: detailState.maybeWhen(
        loaded: (announcement) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(BaseSize.w16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and Global Badge
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w12,
                        vertical: BaseSize.h6,
                      ),
                      decoration: BoxDecoration(
                        color: BaseColor.primaryInspire.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                      ),
                      child: Text(
                        announcement.kategori,
                        style: BaseTypography.bodyMedium
                            .copyWith(color: BaseColor.primaryInspire)
                            .toBold,
                      ),
                    ),
                    Gap.w8,
                    if (announcement.isGlobal)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: BaseSize.w12,
                          vertical: BaseSize.h6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            BaseSize.radiusSm,
                          ),
                        ),
                        child: Text(
                          'Global',
                          style: BaseTypography.bodyMedium
                              .copyWith(color: Colors.orange)
                              .toBold,
                        ),
                      ),
                  ],
                ),
                Gap.h16,

                // Title
                Text(
                  announcement.judul,
                  style: BaseTypography.headlineSmall.toBold,
                ),
                Gap.h12,

                // Dosen Info
                if (announcement.dosen != null)
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: EdgeInsets.all(BaseSize.w12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: BaseColor.primaryInspire,
                            child: Icon(Icons.person, color: BaseColor.white),
                          ),
                          Gap.w12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  announcement.dosen!.name,
                                  style: BaseTypography.bodyLarge.toBold,
                                ),
                                Gap.h4,
                                Text(
                                  'NIP: ${announcement.dosen!.nip}',
                                  style: BaseTypography.bodySmall.toGrey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Gap.h16,

                // Created Date
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: BaseColor.grey),
                    Gap.w4,
                    Text(
                      Jiffy.parse(announcement.createdAt.toString()).yMMMMd,
                      style: BaseTypography.bodySmall.toGrey,
                    ),
                    Gap.w8,
                    Text(
                      '(${Jiffy.parse(announcement.createdAt.toString()).fromNow()})',
                      style: BaseTypography.bodySmall.toGrey,
                    ),
                  ],
                ),
                Gap.h24,

                // Content
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(BaseSize.w16),
                  decoration: BoxDecoration(
                    color: BaseColor.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  ),
                  child: Text(
                    announcement.isi,
                    style: BaseTypography.bodyLarge,
                  ),
                ),
                Gap.h24,

                // Class Tags
                if (announcement.kelas != null &&
                    announcement.kelas!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kelas Terkait',
                        style: BaseTypography.titleMedium.toBold,
                      ),
                      Gap.h12,
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: announcement.kelas!
                            .map(
                              (kelas) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: BaseSize.w12,
                                  vertical: BaseSize.h8,
                                ),
                                decoration: BoxDecoration(
                                  color: BaseColor.grey.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                    BaseSize.radiusSm,
                                  ),
                                  border: Border.all(
                                    color: BaseColor.grey.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      kelas.kode,
                                      style: BaseTypography.bodyMedium.toBold,
                                    ),
                                    Text(
                                      kelas.nama,
                                      style: BaseTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              Gap.h16,
              Text(
                message,
                style: BaseTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              Gap.h16,
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(
                        announcementDetailControllerProvider(
                          announcementId,
                        ).notifier,
                      )
                      .loadAnnouncementDetail();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}
