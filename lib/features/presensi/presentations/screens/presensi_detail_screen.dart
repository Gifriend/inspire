import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/extensions/extension.dart';
import 'package:inspire/core/widgets/widgets.dart';

import '../../../presentation.dart';

class PresensiDetailScreen extends ConsumerStatefulWidget {
  const PresensiDetailScreen({super.key, required this.type});

  final PresensiType type;

  @override
  ConsumerState<PresensiDetailScreen> createState() =>
      _PresensiDetailScreenState();
}

class _PresensiDetailScreenState extends ConsumerState<PresensiDetailScreen> {
  late final TextEditingController _presensiController;

  @override
  void initState() {
    super.initState();
    _presensiController = TextEditingController();
  }

  @override
  void dispose() {
    _presensiController.dispose();
    super.dispose();
  }

  String _getTitle() {
    switch (widget.type) {
      case PresensiType.uas:
        return 'Presensi UAS';
      case PresensiType.kelas:
        return 'Presensi Kelas';
      case PresensiType.event:
        return 'Presensi Event';
    }
  }

  String _getSubtitle() {
    switch (widget.type) {
      case PresensiType.uas:
        return 'Presensi UAS';
      case PresensiType.kelas:
        return 'Presensi Kelas';
      case PresensiType.event:
        return 'Presensi Event';
    }
  }

  String _getInputHint() {
    switch (widget.type) {
      case PresensiType.uas:
        return 'Masukkan Kode Presensi UAS';
      case PresensiType.kelas:
        return 'Masukkan Kode Presensi Kelas';
      case PresensiType.event:
        return 'Masukkan Kode Presensi Event';
    }
  }

  String _getHistoryText() {
    switch (widget.type) {
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
      presensiDetailControllerProvider(widget.type).notifier,
    );

    switch (widget.type) {
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
  Widget build(BuildContext context) {
    final state = ref.watch(presensiDetailControllerProvider(widget.type));
    final controller = ref.read(
      presensiDetailControllerProvider(widget.type).notifier,
    );

    ref.listen(presensiDetailControllerProvider(widget.type), (previous, next) {
      final wasLoading = previous?.loading == true;
      final isLoading = next.loading == true;
      if (!wasLoading || isLoading) return;

      final successMessage = next.successMessage;
      final errorMessage = next.errorPresensi;

      if (successMessage != null && successMessage.isNotEmpty) {
        showSuccessAlertDialogWidget(
          context,
          title: successMessage,
          actionButtonTitle: 'OK',
        ).then((_) {
          if (!context.mounted) return;
          controller.clearFeedback();
          context.pop();
        });
        return;
      }

      if (errorMessage != null && errorMessage.isNotEmpty) {
        showErrorAlertDialogWidget(
          context,
          title: 'Presensi gagal',
          subtitle: errorMessage,
        ).then((_) {
          if (!context.mounted) return;
          controller.clearFeedback();
        });
      }
    });

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
      child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: BaseSize.w20, vertical: BaseSize.h24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text(
              //   _getSubtitle(),
              //   style: BaseTypography.titleLarge.toBold,
              //   textAlign: TextAlign.center,
              // ),
              Gap.h24,
              Container(
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
                      textAlign: TextAlign.center,
                    ),
                    Gap.h24,
                    Gap.h12,
                    InputWidget.text(
                      controller: _presensiController,
                      borderColor: BaseColor.black,
                      hint: 'Masukkan Kode Presensi',
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        final upper = (value?.toString() ?? '').toUpperCase();
                        if (_presensiController.text != upper) {
                          _presensiController.value = TextEditingValue(
                            text: upper,
                            selection: TextSelection.collapsed(
                              offset: upper.length,
                            ),
                          );
                        }
                        controller.updatePresensi(upper);
                      },
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
                          borderRadius: BorderRadius.circular(
                            BaseSize.radiusLg,
                          ),
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
                                style: BaseTypography.titleMedium.toWhite
                                    .toBold,
                              ),
                      ),
                    ),
                    Gap.h24,
                  ],
                ),
              ),
              Gap.h20,
              Text(
                _getHistoryText(),
                style: BaseTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
    );
  }
}
