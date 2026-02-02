import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';

import '../../../core/assets/assets.dart';
import '../../../core/constants/constants.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    // final size = MediaQuery.of(context).size;

    return ScaffoldWidget(
      loading: profileState.maybeWhen(
        loading: () => true,
        orElse: () => false,
      ),
      child: profileState.maybeWhen(
        loaded: (user) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(BaseSize.h12),
            decoration: BoxDecoration(
              color: BaseColor.primaryInspire,
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
                    Assets.icons.app.user.path,
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
                        style: BaseTypography.titleMedium.toBold.toWhite,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap.h6,
                      Text(
                        user.nim,
                        style: BaseTypography.titleMedium.toWhite,
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
                      Text('4.00', style: BaseTypography.headlineSmall),
                    ],
                  ),
                  Gap.w28,
                  Column(
                    children: [
                      Text('SMESTER', style: BaseTypography.titleSmall.toBold),
                      Text('7', style: BaseTypography.headlineSmall),
                    ],
                  ),
                  Gap.w28,
                  Column(
                    children: [
                      Text(
                        'SKS LULUS',
                        style: BaseTypography.titleSmall.toBold,
                      ),
                      Text('138', style: BaseTypography.headlineSmall),
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
                      'Teknik',
                      style: BaseTypography.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Teknik Informatika',
                      style: BaseTypography.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Strata 1',
                      style: BaseTypography.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Aktif',
                      style: BaseTypography.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
        orElse: () => const Center(
          child: Text('Gagal memuat profil'),
        ),
      ),
    );
  }
}
