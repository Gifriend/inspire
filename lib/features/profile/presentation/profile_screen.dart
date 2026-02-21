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
          final identityLabel = isLecturer ? 'NIP' : 'NIM';
          final identityValue = isLecturer
              ? (user.nip ?? user.nim ?? '-')
              : (user.nim ?? user.nip ?? '-');

          final ipkValue =
              user.ipk?.toStringAsFixed(2) ?? (isLecturer ? '-' : '0.00');
          final semesterValue =
              user.semesterTerakhir ?? (isLecturer ? '-' : '0');
          final sksLulusValue =
              user.totalSksLulus?.toString() ?? (isLecturer ? '-' : '0');

          final fakultasValue = user.fakultas?.name ?? '-';
          final prodiValue = user.prodi?.name ?? '-';
          final jenjangValue = user.prodi?.jenjang ?? '-';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(BaseSize.h12),
                decoration: BoxDecoration(
                  color: BaseColor.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.grey,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                        color: BaseColor.white,
                        boxShadow: [
                          BoxShadow(
                            color: BaseColor.grey,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        user.photo ?? Assets.icons.app.user.path,
                        height: BaseSize.h72,
                        width: BaseSize.w64,
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: BaseTypography.titleMedium.toBold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Gap.h6,
                          Text(
                            '$identityLabel: $identityValue',
                            style: BaseTypography.titleMedium,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Gap.h16,
              Container(
                height: BaseSize.h64,
                decoration: BoxDecoration(
                  color: BaseColor.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.grey,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: BaseSize.h8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text('IPK', style: BaseTypography.titleSmall.toBold),
                          Text(ipkValue, style: BaseTypography.headlineSmall),
                        ],
                      ),
                      Gap.w28,
                      Column(
                        children: [
                          Text(
                            'SMESTER',
                            style: BaseTypography.titleSmall.toBold,
                          ),
                          Text(
                            semesterValue,
                            style: BaseTypography.headlineSmall,
                          ),
                        ],
                      ),
                      Gap.w28,
                      Column(
                        children: [
                          Text(
                            'SKS LULUS',
                            style: BaseTypography.titleSmall.toBold,
                          ),
                          Text(
                            sksLulusValue,
                            style: BaseTypography.headlineSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Gap.h24,
              Container(
                height: BaseSize.customWidth(200.0),
                padding: EdgeInsets.only(left: BaseSize.w20),
                decoration: BoxDecoration(
                  color: BaseColor.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.grey,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Fakultas  :', style: BaseTypography.titleLarge),
                        Text('Prodi       :', style: BaseTypography.titleLarge),
                        Text('Jenjang    :', style: BaseTypography.titleLarge),
                        Text('Status     :', style: BaseTypography.titleLarge),
                      ],
                    ),
                    Gap.w20,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          fakultasValue,
                          style: BaseTypography.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          prodiValue,
                          style: BaseTypography.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          jenjangValue,
                          style: BaseTypography.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.status,
                          style: BaseTypography.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
        ref.read(profileControllerProvider.notifier).clearCache();
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
