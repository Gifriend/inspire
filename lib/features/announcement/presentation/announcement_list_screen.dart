import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/announcement/presentation/announcement_controller.dart';
import 'package:inspire/features/presentation.dart';
import 'package:jiffy/jiffy.dart';

class AnnouncementListScreen extends ConsumerStatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  ConsumerState<AnnouncementListScreen> createState() =>
      _AnnouncementListScreenState();
}

class _AnnouncementListScreenState
    extends ConsumerState<AnnouncementListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(announcementControllerProvider.notifier).loadAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final announcementState = ref.watch(announcementControllerProvider);

    return ScaffoldWidget(
      appBar: AppBar(
        title: Text(
          'Pengumuman',
          style: BaseTypography.titleLarge.toBold,
        ),
        backgroundColor: BaseColor.primaryInspire,
        foregroundColor: BaseColor.white,
      ),
      loading: announcementState.maybeWhen(
        loading: () => true,
        orElse: () => false,
      ),
      child: announcementState.maybeWhen(
        loaded: (announcements) {
          if (announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.announcement_outlined,
                    size: 64,
                    color: BaseColor.grey,
                  ),
                  Gap.h16,
                  Text(
                    'Belum ada pengumuman',
                    style: BaseTypography.bodyLarge.toGrey,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(BaseSize.w12),
            itemCount: announcements.length,
            separatorBuilder: (context, index) => Gap.h12,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                ),
                child: InkWell(
                  onTap: () {
                    context.pushNamed(
                      AppRoute.announcementDetail,
                      pathParameters: {'id': announcement.id.toString()},
                    );
                  },
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  child: Padding(
                    padding: EdgeInsets.all(BaseSize.w12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: BaseSize.w8,
                                vertical: BaseSize.h4,
                              ),
                              decoration: BoxDecoration(
                                color: BaseColor.primaryInspire.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(BaseSize.radiusSm),
                              ),
                              child: Text(
                                announcement.kategori,
                                style: BaseTypography.bodySmall
                                    .copyWith(color: BaseColor.primaryInspire),
                              ),
                            ),
                            Gap.w8,
                            if (announcement.isGlobal)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: BaseSize.w8,
                                  vertical: BaseSize.h4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(BaseSize.radiusSm),
                                ),
                                child: Text(
                                  'Global',
                                  style: BaseTypography.bodySmall
                                      .copyWith(color: Colors.orange),
                                ),
                              ),
                          ],
                        ),
                        Gap.h8,
                        Text(
                          announcement.judul,
                          style: BaseTypography.titleMedium.toBold,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap.h4,
                        Text(
                          announcement.isi,
                          style: BaseTypography.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap.h8,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (announcement.dosen != null)
                              Text(
                                announcement.dosen!.name,
                                style: BaseTypography.bodySmall.toGrey,
                              ),
                            Text(
                              Jiffy.parse(announcement.createdAt.toString())
                                  .fromNow(),
                              style: BaseTypography.bodySmall.toGrey,
                            ),
                          ],
                        ),
                        if (announcement.kelas != null &&
                            announcement.kelas!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Gap.h8,
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: announcement.kelas!
                                    .take(3)
                                    .map(
                                      (kelas) => Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: BaseSize.w6,
                                          vertical: BaseSize.h4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: BaseColor.grey.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                              BaseSize.radiusSm),
                                        ),
                                        child: Text(
                                          '${kelas.kode} - ${kelas.nama}',
                                          style: BaseTypography.bodySmall,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
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
                      .read(announcementControllerProvider.notifier)
                      .loadAnnouncements();
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
