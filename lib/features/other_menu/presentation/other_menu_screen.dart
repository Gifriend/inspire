import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/widgets/appbar/appbar_widget.dart';

import '../../../core/constants/constants.dart';
import '../../../core/routing/app_routing.dart';
import '../../../core/utils/extensions/extension.dart';

class OtherMenuScreen extends ConsumerWidget {
  const OtherMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBarWidget(title: 'Menu Lainnya'),
      body:SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap.h32,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMenuList(),
                      ],
                    ),
                  ),
                  Gap.h72,
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildMenuList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (context, index) => Gap.h12,
      itemBuilder: (context, index) {
        return _buildMenuItemByIndex(context, index);
      },
    );
  }

  Widget _buildMenuItemByIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        return _buildMenuCard(
          icon: Icons.assignment,
          title: 'Kartu Hasil Studi (KHS)',
          subtitle: 'Lihat hasil studi per semester',
          onTap: () => context.pushNamed(AppRoute.khs),
        );
      case 1:
        return _buildMenuCard(
          icon: Icons.description,
          title: 'Transkrip Nilai',
          subtitle: 'Lihat transkrip nilai lengkap',
          onTap: () => context.pushNamed(AppRoute.transcript),
        );
      case 2:
        return _buildMenuCard(
          icon: Icons.calendar_month,
          title: 'Jadwal Kuliah',
          subtitle: 'Lihat jadwal perkuliahan',
          onTap: () {
            // TODO: Implement jadwal navigation
          },
        );
      case 3:
        return _buildMenuCard(
          icon: Icons.money,
          title: 'Keuangan',
          subtitle: 'Info pembayaran dan tagihan',
          onTap: () {
            // TODO: Implement keuangan navigation
          },
        );
      case 4:
        return _buildMenuCard(
          icon: Icons.library_books,
          title: 'Perpustakaan',
          subtitle: 'Akses koleksi perpustakaan',
          onTap: () {
            // TODO: Implement perpustakaan navigation
          },
        );
      case 5:
        return _buildMenuCard(
          icon: Icons.help_outline,
          title: 'Bantuan & Dukungan',
          subtitle: 'Hubungi tim support',
          onTap: () {
            // TODO: Implement bantuan navigation
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      child: Container(
        padding: EdgeInsets.all(BaseSize.w16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(BaseSize.w12),
              decoration: BoxDecoration(
                color: BaseColor.primaryInspire.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: Icon(
                icon,
                color: BaseColor.primaryInspire,
                size: 24,
              ),
            ),
            Gap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: BaseTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    subtitle,
                    style: BaseTypography.bodySmall.toGrey,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
