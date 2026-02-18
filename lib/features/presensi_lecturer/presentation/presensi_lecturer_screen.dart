import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/widgets/widgets.dart';

class PresensiLecturerScreen extends ConsumerStatefulWidget {
  const PresensiLecturerScreen({super.key});

  @override
  ConsumerState<PresensiLecturerScreen> createState() => _PresensiLecturerScreenState();
}

class _PresensiLecturerScreenState extends ConsumerState<PresensiLecturerScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: 'Presensi Mahasiswa',
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.how_to_reg,
              size: 64,
              color: BaseColor.primaryInspire.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Presensi Dosen',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: BaseColor.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Fitur presensi untuk dosen sedang dalam pengembangan.\nGunakan menu di Dashboard untuk mengakses fitur dosen lainnya.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: BaseColor.primaryText.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}