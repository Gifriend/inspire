import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/models.dart';
import 'package:inspire/core/services/presensi_history_service.dart';
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
  List<PresensiHistoryItem> _history = const [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _presensiController = TextEditingController();
    Future.microtask(_loadHistory);
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

  Future<void> _loadHistory() async {
    final history = await ref
        .read(presensiHistoryServiceProvider)
        .getHistory(widget.type);

    if (!mounted) {
      return;
    }

    setState(() {
      _history = history;
      _loadingHistory = false;
    });
  }

  void _useHistoryToken(
    PresensiHistoryItem item,
    PresensiDetailController controller,
  ) {
    final token = item.token.toUpperCase();
    _presensiController.value = TextEditingValue(
      text: token,
      selection: TextSelection.collapsed(offset: token.length),
    );
    controller.updatePresensi(token);
  }

  Widget _buildHistorySection(PresensiDetailController controller) {
    if (_loadingHistory) {
      return Padding(
        padding: EdgeInsets.only(top: BaseSize.h16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_history.isEmpty) {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: BaseSize.h16),
        padding: EdgeInsets.all(BaseSize.w16),
        decoration: BoxDecoration(
          color: BaseColor.white,
          borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        ),
        child: Text(
          'Belum ada riwayat kode presensi yang berhasil dikirim.',
          style: BaseTypography.bodyMedium.toGrey,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: BaseSize.h16),
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w16,
        vertical: BaseSize.h8,
      ),
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      ),
      child: Column(
        children: _history
            .map(
              (item) => InkWell(
                onTap: () => _useHistoryToken(item, controller),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: EdgeInsets.all(BaseSize.w8),
                        decoration: BoxDecoration(
                          color: BaseColor.primaryInspire.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                        ),
                        child: Icon(
                          Icons.history,
                          size: 18,
                          color: BaseColor.primaryInspire,
                        ),
                      ),
                      Gap.w12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.token,
                              style: BaseTypography.titleMedium.toBold,
                            ),
                            Gap.h4,
                            Text(
                              item.message,
                              style: BaseTypography.bodySmall.toGrey,
                            ),
                            Gap.h4,
                            Text(
                              '${item.submittedAt.slashDate} ${item.submittedAt.HHmm}',
                              style: BaseTypography.bodySmall.toGrey,
                            ),
                          ],
                        ),
                      ),
                      Gap.w8,
                      Text(
                        'Gunakan',
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.primaryInspire,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
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
        _loadHistory();
        _presensiController.clear();
        controller.updatePresensi('');
        showSuccessAlertDialogWidget(
          context,
          title: successMessage,
          actionButtonTitle: 'OK',
        ).then((_) {
          if (!context.mounted) return;
          controller.clearFeedback();
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
              _buildHistorySection(controller),
            ],
          ),
        ),
    );
  }
}
