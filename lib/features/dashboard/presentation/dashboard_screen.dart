import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      disablePadding: true,
      child: SafeArea(
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
                    Text(
                      'Selamat Datang!',
                      style: BaseTypography.headlineSmall,
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(Assets.icons.fill.notification.path),
                        Gap.w12,
                        SvgPicture.asset(Assets.icons.fill.user.path),
                      ],
                    ),
                  ],
                ),
              ),
              Gap.h20,
              Padding(
                padding: EdgeInsets.only(
                  left: BaseSize.w12,
                  right: BaseSize.w12,
                ),
                child: Container(
                  height: 175.0,
                  decoration: BoxDecoration(
                    color: Colors.red.shade300,
                    borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 5,
                        right: 15,
                        child: Row(
                          children: [
                            Text('IPK: 4.00'),
                            Gap.w12,
                            Text('SKS lulus: 120'),
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
                              Text(
                                'Gifriend Yedija Talumingan',
                                style: BaseTypography.bodyMedium,
                              ),
                              Gap.h6,
                              Text(
                                'Teknik Informatika',
                                style: BaseTypography.bodyMedium,
                              ),
                              Gap.h6,
                              Text(
                                '220211060328',
                                style: BaseTypography.bodyMedium,
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
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: BaseColor.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
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
                      icon: Assets.images.khs,
                      label: 'KHS',
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
                      icon: Assets.images.chatBoxOnly,
                      label: 'chat',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Assets.icons.fill.other,
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
                    Text('Pengumuman', style: BaseTypography.titleLarge),
                    Text('Lihat semua', style: BaseTypography.titleMedium),
                  ],
                ),
              ),
            ],
          ),
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
                    color: Colors.grey.withOpacity(0.3),
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
      return icon.svg(width: 24.0, height: 24.0, color: Colors.grey[700]);
    } else if (icon is AssetGenImage) {
      return icon.image(width: 24.0, height: 24.0, color: Colors.grey[700]);
    } else {
      return const SizedBox.shrink();
    }
  }
}
