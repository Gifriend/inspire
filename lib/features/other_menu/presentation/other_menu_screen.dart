import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/widgets/appbar/appbar_widget.dart';

import '../../../core/constants/constants.dart';
import '../../../core/routing/app_routing.dart';
import '../../../core/utils/extensions/extension.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../profile/presentation/profile_state.dart';

class OtherMenuScreen extends ConsumerWidget {
  const OtherMenuScreen({super.key});

  bool _isLecturerRole(String role) {
    final r = role.trim().toUpperCase();
    return r == 'DOSEN' || r == 'KOORPRODI' || r == 'LECTURER';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final isLecturer = profileState.maybeWhen(
      loaded: (user) => _isLecturerRole(user.role),
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBarWidget(title: 'Menu Lainnya'),
      body: SafeArea(
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
                        _buildMenuList(context, isLecturer),
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

  Widget _buildMenuList(BuildContext context, bool isLecturer) {
    if (isLecturer) {
      return _buildLecturerMenuList(context);
    }
    return _buildStudentMenuList(context);
  }

  // ─── Mahasiswa menus ──────────────────────────────────────────────────────

  Widget _buildStudentMenuList(BuildContext context) {
    final items = [
      _MenuItem(
        icon: Icons.assignment,
        title: 'Kartu Hasil Studi (KHS)',
        subtitle: 'Lihat hasil studi per semester',
        onTap: () => context.pushNamed(AppRoute.khs),
      ),
      _MenuItem(
        icon: Icons.description,
        title: 'Transkrip Nilai',
        subtitle: 'Lihat transkrip nilai lengkap',
        onTap: () => context.pushNamed(AppRoute.transcript),
      ),
      _MenuItem(
        icon: Icons.calendar_month,
        title: 'Jadwal Kuliah',
        subtitle: 'Lihat jadwal perkuliahan',
        onTap: () => context.pushNamed(AppRoute.schedule),
      ),
    ];
    return _buildItemList(context, items);
  }

  // ─── Dosen menus ───────────────────────────────────────────────────────────

  Widget _buildLecturerMenuList(BuildContext context) {
    final items = [
      _MenuItem(
        icon: Icons.grade,
        title: 'Input Nilai Mahasiswa',
        subtitle: 'Berikan nilai untuk kelas yang Anda ampu',
        onTap: () => context.pushNamed(AppRoute.myClassesLecturer),
      ),
      _MenuItem(
        icon: Icons.people_alt,
        title: 'Mahasiswa Bimbingan PA',
        subtitle: 'Lihat daftar mahasiswa bimbingan akademik Anda',
        onTap: () => context.pushNamed(AppRoute.lecturerPaMahasiswaList),
      ),
      _MenuItem(
        icon: Icons.calendar_month,
        title: 'Jadwal Mengajar',
        subtitle: 'Lihat jadwal perkuliahan Anda',
        onTap: () => context.pushNamed(AppRoute.schedule),
      ),
    ];
    return _buildItemList(context, items);
  }

  Widget _buildItemList(BuildContext context, List<_MenuItem> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => Gap.h12,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildMenuCard(
          icon: item.icon,
          title: item.title,
          subtitle: item.subtitle,
          onTap: item.onTap,
        );
      },
    );
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

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
