import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/transcript/transcript_model.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'package:path_provider/path_provider.dart';

class TranscriptScreen extends ConsumerStatefulWidget {
  const TranscriptScreen({super.key});

  @override
  ConsumerState<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends ConsumerState<TranscriptScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transcriptControllerProvider.notifier).loadTranscript();
    });
  }

  Future<void> _handleDownloadPdf() async {
    setState(() => _isDownloading = true);
    try {
      debugPrint('Starting Transkrip PDF download');
      
      final bytes =
          await ref.read(transcriptControllerProvider.notifier).downloadPdf();
      
      debugPrint('Received ${bytes.length} bytes from server');
      
      if (bytes.isEmpty) throw Exception('File PDF kosong - tidak ada data yang diterima');
      
      final filename = 'Transkrip_Nilai.pdf';

      if (Platform.isAndroid) {
        try {
          // Execute method to MainActivity
          final channel = const MethodChannel(
            'com.gifriend.inspire/file_saver',
          );
          debugPrint('Calling native save via MethodChannel, bytes length: ${bytes.length}');
          final base64Str = base64Encode(bytes);
          debugPrint('Base64 encoded length: ${base64Str.length}');
          
          final res = await channel.invokeMethod<String>(
            'saveFileToDownloads',
            {'base64': base64Str, 'filename': filename},
          );

          if (res != null && res.isNotEmpty) {
            debugPrint('Native save returned: $res');
            // Verify file exists
            final resFile = File(res);
            if (resFile.existsSync()) {
              debugPrint('File verified to exist at: $res');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('File disimpan: $res'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
              return;
            } else if (res.startsWith('content://')) {
              debugPrint(' Native returned content URI: $res');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(' File disimpan ke folder Downloads'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 5),
                  ),
                );
              }
              return;
            }
          }
        } catch (e) {
          debugPrint('Native save error: $e');
        }
      }

      // Fallback: Try to save to public Downloads folder
      Directory? saveDir;
      
      // First, try public Downloads
      try {
        final publicDownloads = Directory('/storage/emulated/0/Download');
        if (publicDownloads.existsSync()) {
          saveDir = publicDownloads;
          debugPrint('Using public Downloads: ${publicDownloads.path}');
        }
      } catch (_) {}

      // If not available, try getExternalStorageDirectories
      if (saveDir == null) {
        try {
          if (Platform.isAndroid) {
            final dirs = await getExternalStorageDirectories(
              type: StorageDirectory.downloads,
            );
            if (dirs != null && dirs.isNotEmpty) {
              saveDir = dirs.first;
              debugPrint('Using getExternalStorageDirectories: ${saveDir.path}');
            }
          }
        } catch (e) {
          debugPrint('getExternalStorageDirectories failed: $e');
        }
      }

      // For desktop platforms, try getDownloadsDirectory
      if (saveDir == null) {
        try {
          final downloads = await getDownloadsDirectory();
          if (downloads != null) {
            saveDir = downloads;
            debugPrint('Using getDownloadsDirectory: ${downloads.path}');
          }
        } catch (e) {
          debugPrint('getDownloadsDirectory failed: $e');
        }
      }

      // Fallback to application documents (private, no permission needed)
      if (saveDir == null) {
        saveDir = await getApplicationDocumentsDirectory();
        debugPrint('Fallback to app documents: ${saveDir.path}');
      }

      final file = File('${saveDir.path}/$filename');
      debugPrint('Saving file to: ${file.path}');
      await file.writeAsBytes(bytes);

      // Verify file was saved
      if (file.existsSync()) {
        final savedFileSize = file.lengthSync();
        debugPrint('File successfully saved at: ${file.path} (size: $savedFileSize bytes)');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File disimpan: ${file.path}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        throw Exception('File not saved or not accessible at ${file.path}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final transcriptState = ref.watch(transcriptControllerProvider);

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: 'Transkrip Nilai',
        leadIcon: Assets.icons.fill.arrowBack,
        onPressedLeadIcon: () => context.pop(),
        actions: [
          _isDownloading
              ? Padding(
                  padding: EdgeInsets.all(BaseSize.w12),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.download, color: BaseColor.white),
                  onPressed: transcriptState.maybeWhen(
                    loaded: (_) => _handleDownloadPdf,
                    orElse: () => null,
                  ),
                  tooltip: 'Unduh Transkrip PDF',
                ),
        ],
      ),
      loading: transcriptState.maybeWhen(
        loading: () => true,
        orElse: () => false,
      ),
      child: transcriptState.when(
        initial: () => const Center(child: Text('Memuat...')),
        loading: () => const SizedBox.shrink(),
        loaded: (transcript) => _buildContent(transcript),
        error: (message) => _buildError(message),
      ),
    );
  }

  Widget _buildContent(TranscriptModel transcript) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(BaseSize.w16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMahasiswaCard(transcript.mahasiswa),
          Gap.h16,
          _buildStatistikCard(transcript.statistik),
          Gap.h24,

          // Per-semester sections
          Text(
            'Daftar Nilai per Semester',
            style: BaseTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Gap.h12,
          ...transcript.bySemester
              .map((sem) => _buildSemesterSection(sem))
              .toList(),

          Gap.h8,
          // Grand summary rows
          _buildGrandSummary(transcript.statistik),
          Gap.h24,

          // Download button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isDownloading ? null : _handleDownloadPdf,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.print),
              label: Text(_isDownloading ? 'Mengunduh...' : 'Cetak Transkrip (PDF)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BaseColor.primaryInspire,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                ),
              ),
            ),
          ),
          Gap.h24,
        ],
      ),
    );
  }

  Widget _buildMahasiswaCard(TranskripMahasiswaModel m) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Nama', m.nama),
      if (m.tempatLahir != null)
        MapEntry('Tempat / Tanggal Lahir', '${m.tempatLahir}, ${m.tanggalLahir ?? '-'}')
      else if (m.tanggalLahir != null)
        MapEntry('Tanggal Lahir', m.tanggalLahir!),
      MapEntry('NIM', m.nim),
      MapEntry('Program Studi / Jenjang', '${m.prodi} / ${m.jenjang}'),
      MapEntry('Fakultas', m.fakultas),
      MapEntry('Angkatan', m.angkatan),
      MapEntry('Tanggal Cetak', m.tanggalCetak),
    ];
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: rows.map((e) {
          return Padding(
            padding: EdgeInsets.only(bottom: BaseSize.h6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 145,
                  child: Text(e.key, style: BaseTypography.bodySmall.toGrey),
                ),
                Text(': ', style: BaseTypography.bodySmall.toGrey),
                Expanded(
                  child: Text(
                    e.value,
                    style: BaseTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatistikCard(TranskripStatistikModel stat) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: BaseColor.primaryInspire,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        boxShadow: [
          BoxShadow(
            color: BaseColor.primaryInspire.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Indeks Prestasi Kumulatif',
              style: BaseTypography.titleMedium.toWhite),
          Gap.h6,
          Text(
            stat.ipk,
            style: BaseTypography.headlineLarge.toBold.toWhite,
          ),
          Gap.h4,
          Text(stat.predikat, style: BaseTypography.bodyLarge.toWhite),
          Gap.h16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total SKS', '${stat.totalSKS}'),
              Container(width: 1, height: 36, color: Colors.white30),
              _buildStatItem('Mata Kuliah', '${stat.totalMataKuliah}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: BaseTypography.bodySmall.toWhite),
        Gap.h4,
        Text(value,
            style: BaseTypography.titleLarge.toBold.toWhite),
      ],
    );
  }

  Widget _buildSemesterSection(TranskripSemesterModel sem) {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 11,
      color: Colors.white,
    );
    const cellStyle = TextStyle(fontSize: 11);

    return Padding(
      padding: EdgeInsets.only(bottom: BaseSize.h16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Semester header bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF555555),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(BaseSize.radiusSm),
                topRight: Radius.circular(BaseSize.radiusSm),
              ),
            ),
            child: Text(
              '${sem.label}  (${sem.academicYear})',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),

          // Grade table
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(BaseSize.radiusSm),
                bottomRight: Radius.circular(BaseSize.radiusSm),
              ),
            ),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(28),  // No
                1: FixedColumnWidth(68),  // Kode
                2: FlexColumnWidth(),     // Nama MK
                3: FixedColumnWidth(34),  // SKS
                4: FixedColumnWidth(38),  // Nilai
                5: FixedColumnWidth(42),  // Angka
                6: FixedColumnWidth(50),  // Nil.SKS
              },
              border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
              children: [
                // Column header
                TableRow(
                  decoration:
                      BoxDecoration(color: BaseColor.primaryInspire.withValues(alpha: 0.85)),
                  children: [
                    _tc('No', headerStyle, TextAlign.center),
                    _tc('Kode', headerStyle, TextAlign.center),
                    _tc('Mata Kuliah', headerStyle, TextAlign.left),
                    _tc('SKS', headerStyle, TextAlign.center),
                    _tc('Nilai', headerStyle, TextAlign.center),
                    _tc('Angka', headerStyle, TextAlign.center),
                    _tc('Nil.\nSKS', headerStyle, TextAlign.center),
                  ],
                ),
                // Data rows
                ...sem.matakuliah.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final mk = entry.value;
                  final rowBg = idx.isOdd
                      ? const Color(0xFFF7F7F7)
                      : Colors.white;
                  final gradeColor = _gradeColor(mk.nilaiHuruf);
                  return TableRow(
                    decoration: BoxDecoration(color: rowBg),
                    children: [
                      _tc('${mk.no}', cellStyle, TextAlign.center),
                      _tc(mk.kode, cellStyle, TextAlign.left),
                      _tc(mk.nama, cellStyle, TextAlign.left),
                      _tc('${mk.sks}', cellStyle, TextAlign.center),
                      _tcGrade(mk.nilaiHuruf, gradeColor),
                      _tc(mk.indeks.toStringAsFixed(2), cellStyle, TextAlign.center),
                      _tc(mk.nilaiSks.toStringAsFixed(2), cellStyle, TextAlign.right),
                    ],
                  );
                }),
                // Sub-total row
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
                  children: [
                    _tc('', cellStyle, TextAlign.center),
                    _tc('', cellStyle, TextAlign.center),
                    _tc(
                      'Sub Total',
                      const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                      TextAlign.left,
                    ),
                    _tc(
                      '${sem.subTotal.sks}',
                      const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                      TextAlign.center,
                    ),
                    _tc('', cellStyle, TextAlign.center),
                    _tc('', cellStyle, TextAlign.center),
                    _tc(
                      sem.subTotal.nilaiSks.toStringAsFixed(2),
                      const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                      TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrandSummary(TranskripStatistikModel stat) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Total SKS', '${stat.totalSKS}'),
          Gap.h6,
          _buildSummaryRow('Indeks Prestasi Kumulatif (IPK)', stat.ipk),
          Gap.h6,
          _buildSummaryRow('Predikat Kelulusan', stat.predikat),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      children: [
        Expanded(
            child: Text(label, style: BaseTypography.bodySmall)),
        Text(
          ': $value',
          style: BaseTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _tc(String text, TextStyle style, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: Text(text, style: style, textAlign: align),
    );
  }

  Widget _tcGrade(String grade, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            grade,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Gagal memuat transkrip',
              style: BaseTypography.titleMedium),
          Gap.h8,
          Text(
            message,
            style: BaseTypography.bodyMedium
                .copyWith(color: BaseColor.red),
            textAlign: TextAlign.center,
          ),
          Gap.h16,
          ElevatedButton(
            onPressed: () {
              ref
                  .read(transcriptControllerProvider.notifier)
                  .loadTranscript();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'A-':
      case 'B+':
        return Colors.lightGreen.shade700;
      case 'B':
      case 'B-':
        return Colors.blue;
      case 'C+':
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
