
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:jiffy/jiffy.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/models/models.dart';
import '../../../../core/routing/app_routing.dart';
import '../../../presentation.dart';

class AnnouncementSection extends ConsumerWidget {
  const AnnouncementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementState = ref.watch(announcementControllerProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pengumuman', style: BaseTypography.titleLarge.toBold),
              GestureDetector(
                onTap: () => context.pushNamed(AppRoute.announcementList),
                child: Text(
                  'Lihat semua',
                  style: BaseTypography.titleMedium.copyWith(
                    color: BaseColor.primaryInspire,
                  ),
                ),
              ),
            ],
          ),
        ),
        Gap.h20,
        announcementState.maybeWhen(
          loaded: (announcements) {
            if (announcements.isEmpty) {
              return _buildEmptyState();
            }
            return AnnouncementCarousel(
              announcements: announcements.take(5).toList(),
            );
          },
          loading: () => _buildLoadingState(),
          error: (message) => _buildErrorState(message),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 280.0,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: BaseColor.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Belum ada pengumuman',
          style: BaseTypography.bodyLarge.toGrey,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 280.0,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: CircularProgressIndicator(color: BaseColor.primaryInspire),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      height: 280.0,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text('Gagal memuat pengumuman', style: BaseTypography.bodyLarge),
      ),
    );
  }
}

class AnnouncementCarousel extends StatefulWidget {
  final List<AnnouncementModel> announcements;

  const AnnouncementCarousel({super.key, required this.announcements});

  @override
  State<AnnouncementCarousel> createState() => _AnnouncementCarouselState();
}

class _AnnouncementCarouselState extends State<AnnouncementCarousel> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_userInteracting && _pageController.hasClients && mounted) {
        // Logika untuk loop kembali ke awal jika sudah di akhir
        if (_currentPage < widget.announcements.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    if (!mounted) return;
    setState(() => _userInteracting = true);

    Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _userInteracting = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280.0,
      child: PageView.builder(
        physics: const ClampingScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) {
          if (mounted) {
            setState(() => _currentPage = index);
            _stopAutoScroll();
          }
        },
        itemCount: widget.announcements.length,
        itemBuilder: (context, index) {
          return AnnouncementCard(announcement: widget.announcements[index]);
        },
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementCard({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(announcement.id),
      onTap: () {
        context.pushNamed(
          AppRoute.announcementDetail,
          pathParameters: {'id': announcement.id.toString()},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8.0, bottom: 20.0, left: 8.0, right: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            BaseColor.primaryInspire,
                            BaseColor.primaryInspire.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.announcement,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: BaseColor.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                        ),
                        child: Text(
                          announcement.kategori,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (announcement.isGlobal)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                          ),
                          child: const Text(
                            'Global',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                        ),
                        child: Text(
                          Jiffy.parse(announcement.createdAt.toString()).fromNow(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.judul,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap.h4,
                      Expanded(
                        child: Text(
                          announcement.isi,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (announcement.dosen != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.person, size: 12, color: Colors.grey[600]),
                              Gap.w4,
                              Expanded(
                                child: Text(
                                  announcement.dosen!.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}