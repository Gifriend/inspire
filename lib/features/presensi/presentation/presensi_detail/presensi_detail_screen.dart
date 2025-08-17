import 'package:flutter/material.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/extensions/extension.dart';
import 'package:inspire/core/widgets/widgets.dart';

class PresensiDetailScreen extends StatelessWidget {
  const PresensiDetailScreen({super.key, required this.type});

  final PresensiType type;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      disablePadding: true,
      disableSingleChildScrollView: true,
      backgroundColor: BaseColor.cardBackground1,
      appBar: AppBar(
        title: Text(
          'Presensi',
          style: BaseTypography.headlineSmall.toBold.toWhite,
        ),
        backgroundColor: BaseColor.primaryInspire,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap.h16,
          Padding(
            padding: EdgeInsets.only(left: BaseSize.w24),
            child: Text('Presensi', style: BaseTypography.titleLarge.toBold),
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
                    'Masukkan Kode Presensi',
                    style: BaseTypography.titleMedium.toBold,
                  ),
                  Gap.h24,
                  InputWidget.text(borderColor: BaseColor.black),
                  Gap.h24,
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w72,
                        vertical: BaseSize.h12,
                      ),
                      decoration: BoxDecoration(
                        color: BaseColor.blue,
                        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                      ),
                      child: Text(
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
            child: Text(
              'Lihat Riwayat Presensi Anda',
              style: BaseTypography.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
