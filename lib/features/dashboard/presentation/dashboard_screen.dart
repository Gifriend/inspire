import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:inspire/core/utils/extensions/extension.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'package:inspire/features/login/domain/services/login_service.dart';
import 'package:jiffy/jiffy.dart';

import '../../../core/models/models.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
      
  final PageController _pageController = PageController(viewportFraction: 0.75);
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  bool _userInteracting = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    startAutoScroll();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentProfileState = ref.read(profileControllerProvider);

      // Just load if current state is not loaded and not loading
      final bool shouldLoadProfile = currentProfileState.maybeWhen(
        loaded: (_) => false,
        loading: () => false,
        orElse: () => true, // Initial or Error
      );

      if (shouldLoadProfile) {
        ref.read(profileControllerProvider.notifier).loadProfile();
      }

      final currentAnnouncementState = ref.read(announcementControllerProvider);
      final bool shouldLoadAnnouncement = currentAnnouncementState.maybeWhen(
        loaded: (_) => false,
        loading: () => false,
        orElse: () => true,
      );

      if (shouldLoadAnnouncement) {
        ref.read(announcementControllerProvider.notifier).loadAnnouncements();
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _pageController.dispose();
    super.dispose();
  }

  void startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_userInteracting && _pageController.hasClients && mounted) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    if (mounted) {
      setState(() {
        _userInteracting = true;
      });

      // Resume auto scroll after 5 seconds of inactivity
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _userInteracting = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final profileState = ref.watch(profileControllerProvider);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      disablePadding: true,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 2.75,
              width: double.infinity,
              decoration: BoxDecoration(
                color: BaseColor.primaryInspire,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(BaseSize.radiusXl),
                  bottomRight: Radius.circular(BaseSize.radiusXl),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Gap.h24,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang Kembali,',
                              style: BaseTypography.titleSmall.toWhite,
                            ),
                            profileState.maybeWhen(
                              loaded: (user) => Text(
                                user.name,
                                style:
                                    BaseTypography.titleMedium.toBold.toWhite,
                              ),
                              orElse: () => Text(
                                'Loading...',
                                style:
                                    BaseTypography.titleMedium.toBold.toWhite,
                              ),
                            ),
                          ],
                        ),
                        // Row(
                        //   children: [
                        //     SvgPicture.asset(Assets.icons.fill.notification.path),
                        //     Gap.w12,
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  Gap.h24,
                  Padding(
                    padding: EdgeInsets.only(
                      left: BaseSize.w12,
                      right: BaseSize.w12,
                    ),
                    child: Container(
                      height: 125.0,
                      decoration: BoxDecoration(
                        color: BaseColor.white,
                        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 5,
                            right: 15,
                            child: Row(
                              children: [
                                profileState.maybeWhen(
                                  loaded: (user) => Row(
                                    children: [
                                      Text(
                                        'IPK: ${user.ipk?.toStringAsFixed(2) ?? "0.00"}',
                                        style: BaseTypography.bodySmall,
                                      ),
                                      Gap.w12,
                                      Text(
                                        'SKS lulus: ${user.totalSksLulus ?? 0}',
                                        style: BaseTypography.bodySmall,
                                      ),
                                    ],
                                  ),
                                  orElse: () =>
                                      const SizedBox.shrink(), // Munculkan kosong atau loading jika belum siap
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: BaseSize.w20),
                                child: profileState.maybeWhen(
                                  loaded: (user) => Image.asset(
                                    user.photo ?? Assets.icons.app.user.path,
                                    height: BaseSize.h72,
                                    width: BaseSize.w64,
                                  ),
                                  orElse: () => Image.asset(
                                    Assets.icons.app.user.path,
                                    height: BaseSize.h72,
                                    width: BaseSize.w64,
                                  ),
                                ),
                              ),
                              Gap.w12,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  profileState.maybeWhen(
                                    loaded: (user) => Text(
                                      user.name,
                                      style: BaseTypography.bodyMedium,
                                    ),
                                    orElse: () => Text(
                                      'Loading...',
                                      style: BaseTypography.bodyMedium,
                                    ),
                                  ),
                                  Gap.h6,
                                  profileState.maybeWhen(
                                    loaded: (user) => Text(
                                      user.prodi?.name ?? '-',
                                      style: BaseTypography.bodyMedium,
                                    ),
                                    orElse: () => Text(
                                      '-',
                                      style: BaseTypography.bodyMedium,
                                    ),
                                  ),
                                  Gap.h6,
                                  profileState.maybeWhen(
                                    loaded: (user) => Text(
                                      user.nim ?? '-',
                                      style: BaseTypography.bodyMedium,
                                    ),
                                    orElse: () => Text(
                                      '-',
                                      style: BaseTypography.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap.h24,
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: BaseSize.w16),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: BaseColor.white,
                      borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 20,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1,
                      children: [
                        _buildMenuItem(
                          icon: Assets.icons.fill.calendar,
                          label: 'Kalender',
                          onTap: () {
                            // context.pushNamed(AppRoute.ebookMenu);
                          },
                        ),
                        _buildMenuItem(
                          icon: Assets.images.krs,
                          label: 'KRS',
                          onTap: () {
                            // Navigate to KRS with current semester
                            final now = DateTime.now();
                            final year = now.year;
                            final semesterType = now.month >= 8
                                ? 'GANJIL'
                                : 'GENAP';
                            final semester = '$semesterType-$year';

                            context.pushNamed(
                              AppRoute.krs,
                              pathParameters: {'semester': semester},
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Assets.images.pengumuman,
                          label: 'Pengumuman',
                          onTap: () {
                            context.pushNamed(AppRoute.announcementList);
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.book,
                          label: 'E-Learning',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ElearningScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.logout,
                          label: 'Logout',
                          onTap: () => _handleLogout(context),
                        ),
                      ],
                    ),
                  ),
                  Gap.h24,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pengumuman',
                          style: BaseTypography.titleLarge.toBold,
                        ),
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(AppRoute.announcementList);
                          },
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
                  Consumer(
                    builder: (context, ref, child) {
                      final announcementState = ref.watch(
                        announcementControllerProvider,
                      );

                      return announcementState.maybeWhen(
                        loaded: (announcements) {
                          if (announcements.isEmpty) {
                            return Container(
                              height: 280.0,
                              margin: EdgeInsets.symmetric(horizontal: 20),
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

                          // Only show first 5 announcements
                          final displayAnnouncements = announcements
                              .take(5)
                              .toList();

                          return SizedBox(
                            height: 280.0,
                            child: PageView.builder(
                              physics: const ClampingScrollPhysics(),
                              controller: _pageController,
                              onPageChanged: (index) {
                                if (mounted) {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                  _stopAutoScroll();
                                }
                              },
                              itemCount: displayAnnouncements.length,
                              itemBuilder: (context, index) {
                                final announcement =
                                    displayAnnouncements[index];
                                return _buildPengumumanBookCard(
                                  context,
                                  announcement,
                                );
                              },
                            ),
                          );
                        },
                        loading: () => Container(
                          height: 280.0,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: BaseColor.primaryInspire,
                            ),
                          ),
                        ),
                        error: (message) => Container(
                          height: 280.0,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Gagal memuat pengumuman',
                              style: BaseTypography.bodyLarge,
                            ),
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      );
                    },
                  ),
                  Gap.h72,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: BaseColor.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 0,
                    blurRadius: 3,
                    offset: Offset(0.0, 2),
                  ),
                ],
              ),
              child: Center(child: _buildIcon(icon)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(dynamic icon) {
    if (icon is IconData) {
      return Icon(icon, size: 24.0, color: Colors.grey[700]);
    } else if (icon is SvgGenImage) {
      return icon.svg(width: 24.0, height: 24.0);
    } else if (icon is AssetGenImage) {
      return icon.image(width: 24.0, height: 24.0, color: Colors.grey[700]);
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: BaseColor.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(loginServiceProvider).logout();
        if (context.mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
        }
      }
    }
  }
}

Widget _buildPengumumanBookCard(
  BuildContext context,
  AnnouncementModel announcement,
) {
  return GestureDetector(
    key: ValueKey(announcement.id),
    onTap: () {
      context.pushNamed(
        AppRoute.announcementDetail,
        pathParameters: {'id': announcement.id.toString()},
      );
    },
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pengumuman Header with gradient
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
                  // Category Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BaseColor.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                      ),
                      child: Text(
                        announcement.kategori,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Global Badge
                  if (announcement.isGlobal)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(
                            BaseSize.radiusSm,
                          ),
                        ),
                        child: Text(
                          'Global',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Date
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                      ),
                      child: Text(
                        Jiffy.parse(
                          announcement.createdAt.toString(),
                        ).fromNow(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pengumuman Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.judul,
                      style: TextStyle(
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (announcement.dosen != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 12,
                              color: Colors.grey[600],
                            ),
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
