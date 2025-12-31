import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/extensions/extension.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.75);
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  bool _userInteracting = false;

  final List<Map<String, dynamic>> pengumumanVew = [
    {
      'id': '1',
      'title': 'Pengumuman',
      'category': 'Harapan lomba Genera-z berbakti',
      'image': Assets.images.pengumuman2.path,
      'description':
          'Tim UNSRAT berhasil mendapatkan harapan dalam lomba Genera-z berbakti dari bakti bca dan narasi',
    },
    {
      'id': '2',
      'title': 'Pengumuman',
      'category': 'Harapan lomba Genera-z berbakti',
      'image': Assets.images.pengumuman2.path,
      'description':
          'Tim UNSRAT berhasil mendapatkan harapan dalam lomba Genera-z berbakti dari bakti bca dan narasi',
    },
    {
      'id': '3',
      'title': 'Pengumuman',
      'category': 'Harapan lomba Genera-z berbakti',
      'image': Assets.images.pengumuman2.path,
      'description':
          'Tim UNSRAT berhasil mendapatkan harapan dalam lomba Genera-z berbakti dari bakti bca dan narasi',
    },
    {
      'id': '4',
      'title': 'Pengumuman',
      'category': 'Harapan lomba Genera-z berbakti',
      'image': Assets.images.pengumuman2.path,
      'description':
          'Tim UNSRAT berhasil mendapatkan harapan dalam lomba Genera-z berbakti dari bakti bca dan narasi',
    },
  ];

  @override
  void initState() {
    super.initState();
    startAutoScroll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadProfile();
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
        _currentPage = (_currentPage + 1) % pengumumanVew.length;
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
    final profileState = ref.watch(profileControllerProvider);
    
    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      disablePadding: true,
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
            child: SingleChildScrollView(
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
                                style: BaseTypography.titleMedium.toBold.toWhite,
                              ),
                              orElse: () => Text(
                                'Loading...',
                                style: BaseTypography.titleMedium.toBold.toWhite,
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
                                Text(
                                  'IPK: 4.00',
                                  style: BaseTypography.bodySmall,
                                ),
                                Gap.w12,
                                Text(
                                  'SKS lulus: 120',
                                  style: BaseTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: BaseSize.w20),
                                child: Image.asset(
                                  Assets.icons.app.user.path,
                                  height: BaseSize.h72,
                                  width: BaseSize.w64,
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
                                      user.nim,
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
                          label: 'kalender',
                          onTap: () {
                            // context.pushNamed(AppRoute.ebookMenu);
                          },
                        ),
                        _buildMenuItem(
                          icon: Assets.images.krs,
                          label: 'KRS',
                          onTap: () {
                            // context.pushNamed(AppRoute.videoMenu);
                          },
                        ),
                        _buildMenuItem(
                          icon: Assets.images.pengumuman,
                          label: 'Pengumuman',
                          onTap: () {
                            // context.pushNamed(AppRoute.peopleData);
                          },
                        ),
                        _buildMenuItem(
                          icon: Assets.images.transkrip,
                          label: 'Transkrip',
                          onTap: () {},
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
                          icon: Icons.other_houses_outlined,
                          label: 'Lainnya',
                          onTap: () {},
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
                        Text('Lihat semua', style: BaseTypography.titleMedium),
                      ],
                    ),
                  ),
                  Gap.h20,
                  SizedBox(
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
                      itemCount: pengumumanVew.length,
                      itemBuilder: (context, index) {
                        final pengumuman = pengumumanVew[index];
                        return _buildPengumumanBookCard(pengumuman);
                      },
                    ),
                  ),
                  Gap.h72,
                ],
              ),
            ),
          ),
        ],
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
}

Widget _buildPengumumanBookCard(Map<String, dynamic> pengumuman) {
  return GestureDetector(
    key: ValueKey(pengumuman['id']),
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pengumuman Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(pengumuman['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Category Badge
                  Positioned(
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BaseColor.black,
                        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                      ),
                      child: Text(
                        pengumuman['category'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
                      pengumuman['title'],
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
                        pengumuman['description'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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
