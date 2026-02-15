import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/extensions/extension.dart';
import 'package:inspire/core/widgets/widgets.dart';

import '../../../presentation.dart';

class PresensiDetailScreen extends ConsumerWidget {
  const PresensiDetailScreen({super.key, required this.type});

  final PresensiType type;

  String _getTitle() {
    switch (type) {
      case PresensiType.uas:
        return 'Presensi UAS';
      case PresensiType.kelas:
        return 'Presensi Kelas';
      case PresensiType.event:
        return 'Presensi Event';
    }
  }

  String _getSubtitle() {
    switch (type) {
      case PresensiType.uas:
        return 'Presensi UAS';
      case PresensiType.kelas:
        return 'Presensi Kelas';
      case PresensiType.event:
        return 'Presensi Event';
    }
  }

  String _getInputHint() {
    switch (type) {
      case PresensiType.uas:
        return 'Masukkan Kode Presensi UAS';
      case PresensiType.kelas:
        return 'Masukkan Kode Presensi Kelas';
      case PresensiType.event:
        return 'Masukkan Kode Presensi Event';
    }
  }

  String _getHistoryText() {
    switch (type) {
      case PresensiType.uas:
        return 'Lihat Riwayat Presensi UAS Anda';
      case PresensiType.kelas:
        return 'Lihat Riwayat Presensi Kelas Anda';
      case PresensiType.event:
        return 'Lihat Riwayat Presensi Event Anda';
    }
  }

  void _handleSubmit(WidgetRef ref) {
    final controller = ref.read(
      presensiDetailControllerProvider(type).notifier,
    );

    switch (type) {
      case PresensiType.uas:
        controller.submitPresensiUAS();
        break;
      case PresensiType.kelas:
        controller.submitPresensiKelas();
        break;
      case PresensiType.event:
        controller.submitPresensiEvent();
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presensiDetailControllerProvider(type));
    final controller = ref.read(
      presensiDetailControllerProvider(type).notifier,
    );

    return ScaffoldWidget(
      disablePadding: true,
      disableSingleChildScrollView: true,
      backgroundColor: BaseColor.cardBackground1,
      appBar: AppBarWidget(
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
        title: _getTitle(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap.h16,
          Padding(
            padding: EdgeInsets.only(left: BaseSize.w24),
            child: Text(
              _getSubtitle(),
              style: BaseTypography.titleLarge.toBold,
            ),
          ),
          Gap.h40,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
              decoration: BoxDecoration(
                color: BaseColor.white,
                borderRadius: BorderRadius.circular(BaseSize.radiusXl),
              ),
              child: Column(
                children: [
                  Gap.h20,
                  Text(
                    _getInputHint(),
                    style: BaseTypography.titleMedium.toBold,
                  ),
                  Gap.h24,
                  InputWidget.text(
                    borderColor: BaseColor.black,
                    onChanged: controller.updatePresensi,
                    errorText: state.errorPresensi,
                  ),
                  Gap.h24,
                  GestureDetector(
                    onTap: state.loading == true
                        ? null
                        : () => _handleSubmit(ref),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w72,
                        vertical: BaseSize.h12,
                      ),
                      decoration: BoxDecoration(
                        color: state.loading == true
                            ? BaseColor.primaryInspire.withValues(alpha: 0.6)
                            : BaseColor.primaryInspire,
                        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                      ),
                      child: state.loading == true
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: BaseColor.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Kirim',
                              style: BaseTypography.titleMedium.toWhite.toBold,
                            ),
                    ),
                  ),
                  Gap.h24,
                ],
              ),
            ),
          ),
          Gap.h24,
          Center(
            child: Text(_getHistoryText(), style: BaseTypography.titleMedium),
          ),
        ],
      ),
    );
  }
}
