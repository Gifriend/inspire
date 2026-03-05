import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'package:inspire/features/login/domain/services/login_service.dart';

import '../../../core/assets/assets.dart';
import '../../../core/constants/constants.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isLecturerRole(String role) {
    final normalizedRole = role.trim().toUpperCase();
    return normalizedRole == 'DOSEN' ||
        normalizedRole == 'KOORPRODI' ||
        normalizedRole == 'LECTURER';
  }

  bool _isStudentRole(String role) {
    final normalizedRole = role.trim().toUpperCase();
    return normalizedRole == 'MAHASISWA' || normalizedRole == 'STUDENT';
  }

  String _roleLabel(String role) {
    final normalizedRole = role.trim().toUpperCase();
    switch (normalizedRole) {
      case 'MAHASISWA':
      case 'STUDENT':
        return 'Mahasiswa';
      case 'DOSEN':
      case 'LECTURER':
        return 'Dosen';
      case 'KOORPRODI':
        return 'Koordinator Prodi';
      case 'ADMIN':
        return 'Admin';
      default:
        return role;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Widget _buildProfileImage(String? photo) {
    final size = BaseSize.h72;
    final hasPhoto = photo != null && photo.trim().isNotEmpty;
    final imagePath = hasPhoto ? photo.trim() : Assets.icons.app.user.path;
    final isNetworkImage = imagePath.startsWith('http://') ||
        imagePath.startsWith('https://');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BaseSize.radiusXl),
        color: BaseColor.cardBackground1,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BaseSize.radiusXl),
        child: isNetworkImage
            ? Image.network(
                imagePath,
                height: size,
                width: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  Assets.icons.app.user.path,
                  height: size,
                  width: size,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                imagePath,
                height: size,
                width: size,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: BaseSize.h12,
          horizontal: BaseSize.w8,
        ),
        decoration: BoxDecoration(
          color: BaseColor.cardBackground1,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: BaseTypography.labelMedium.toBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Gap.h6,
            Text(
              value,
              style: BaseTypography.titleMedium.toBold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: BaseSize.h8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: BaseSize.customWidth(110),
            child: Text(
              label,
              style: BaseTypography.titleMedium.toBold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: BaseTypography.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final profileState = ref.watch(profileControllerProvider);
    // final size = MediaQuery.of(context).size;

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: 'Profil',
        trailIcon: Assets.svg.logOut,
        trailIconColor: BaseColor.white,
        onPressedTrailIcon: () => _handleLogout(context),
      ),
      loading: profileState.maybeWhen(loading: () => true, orElse: () => false),
      child: profileState.maybeWhen(
        loaded: (user) {
          final isLecturer = _isLecturerRole(user.role);
          final isStudent = _isStudentRole(user.role);
          final identityLabel = isLecturer ? 'NIP' : 'NIM';
          final identityValue = isLecturer
              ? (user.nip ?? user.nim ?? '-')
              : (user.nim ?? user.nip ?? '-');

          final ipkValue = user.ipk?.toStringAsFixed(2) ?? '-';
          final semesterValue = user.semesterTerakhir ?? '-';
          final sksLulusValue = user.totalSksLulus?.toString() ?? '-';

          final fakultasValue = user.fakultas?.name ?? '-';
          final prodiValue = user.prodi?.name ?? '-';
          final jenjangValue = user.prodi?.jenjang ?? '-';
          final roleLabel = _roleLabel(user.role);
          final genderValue = user.gender?.isNotEmpty == true ? user.gender! : '-';
          final alamatValue = user.alamat?.isNotEmpty == true ? user.alamat! : '-';
          final teleponValue =
              user.telepon?.isNotEmpty == true ? user.telepon! : '-';
          final tanggalLahirValue = _formatDate(user.tanggalLahir);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(BaseSize.h16),
                decoration: BoxDecoration(
                  color: BaseColor.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.grey.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildProfileImage(user.photo),
                    Gap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: BaseTypography.titleLarge.toBold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Gap.h6,
                          Text(
                            '$identityLabel: $identityValue',
                            style: BaseTypography.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Gap.h4,
                          Text(
                            roleLabel,
                            style: BaseTypography.bodyMedium.toBold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Gap.h16,
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(BaseSize.h12),
                decoration: BoxDecoration(
                  color: BaseColor.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.grey.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: isStudent
                      ? [
                          _buildStatCard(label: 'IPK', value: ipkValue),
                          Gap.w8,
                          _buildStatCard(label: 'Semester', value: semesterValue),
                          Gap.w8,
                          _buildStatCard(label: 'SKS Lulus', value: sksLulusValue),
                        ]
                      : [
                          _buildStatCard(label: 'Role', value: roleLabel),
                          Gap.w8,
                          _buildStatCard(label: 'Status', value: user.status),
                          Gap.w8,
                          _buildStatCard(label: 'Gender', value: genderValue),
                        ],
                ),
              ),
              Gap.h16,
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(BaseSize.h16),
                decoration: BoxDecoration(
                  color: BaseColor.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.grey.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi Pribadi', style: BaseTypography.titleLarge.toBold),
                    Gap.h12,
                    _buildDetailRow('Email', user.email),
                    _buildDetailRow('Telepon', teleponValue),
                    _buildDetailRow('Alamat', alamatValue),
                    _buildDetailRow('Tanggal Lahir', tanggalLahirValue),
                    _buildDetailRow('Gender', genderValue),
                    _buildDetailRow('Status', user.status),
                  ],
                ),
              ),
              Gap.h16,
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(BaseSize.h16),
                decoration: BoxDecoration(
                  color: BaseColor.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.grey.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi Akademik', style: BaseTypography.titleLarge.toBold),
                    Gap.h12,
                    _buildDetailRow('Fakultas', fakultasValue),
                    _buildDetailRow('Prodi', prodiValue),
                    _buildDetailRow('Jenjang', jenjangValue),
                    if (isStudent) ...[
                      _buildDetailRow('IPK', ipkValue),
                      _buildDetailRow('Semester', semesterValue),
                      _buildDetailRow('Total SKS', sksLulusValue),
                    ] else
                      _buildDetailRow(identityLabel, identityValue),
                  ],
                ),
              ),
              Gap.h24,
            ],
          );
        },
        orElse: () => const Center(child: Text('Gagal memuat profil')),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialogCustomWidget<bool>(
      context: context,
      title: 'Konfirmasi Logout',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Apakah Anda yakin ingin keluar?'),
          Gap.h12,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Logout', style: TextStyle(color: BaseColor.red)),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(loginServiceProvider).logout();
        ref.read(profileControllerProvider.notifier).clearCache();
        if (context.mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          showErrorAlertDialogWidget(
            context,
            title: 'Logout gagal',
            subtitle: '$e',
          );
        }
      }
    }
  }
}
