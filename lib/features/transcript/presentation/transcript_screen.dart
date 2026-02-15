import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TranscriptScreen extends ConsumerStatefulWidget {
  const TranscriptScreen({super.key});

  @override
  ConsumerState<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends ConsumerState<TranscriptScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transcriptControllerProvider.notifier).loadTranscript();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transcriptState = ref.watch(transcriptControllerProvider);

    return ScaffoldWidget(
      appBar: AppBar(
        title: const Text('Transkrip Nilai'),
        backgroundColor: BaseColor.primaryInspire,
        foregroundColor: BaseColor.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () => _handleViewHtml(context),
            tooltip: 'Lihat Detail',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _handleDownload(context),
            tooltip: 'Download Transkrip',
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
        loaded: (transcript) => SingleChildScrollView(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mahasiswa Info Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(BaseSize.w16),
                decoration: BoxDecoration(
                  color: BaseColor.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.grey.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transcript.mahasiswa.nama,
                      style: BaseTypography.titleLarge.toBold,
                    ),
                    Gap.h8,
                    Text(
                      'NIM: ${transcript.mahasiswa.nim}',
                      style: BaseTypography.bodyMedium,
                    ),
                    Gap.h4,
                    Text(
                      transcript.mahasiswa.prodi,
                      style: BaseTypography.bodyMedium,
                    ),
                    Gap.h4,
                    Text(
                      transcript.mahasiswa.fakultas,
                      style: BaseTypography.bodySmall.toGrey,
                    ),
                  ],
                ),
              ),
              Gap.h16,
              
              // Summary Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(BaseSize.w16),
                decoration: BoxDecoration(
                  color: BaseColor.primaryInspire,
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.grey.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Indeks Prestasi Kumulatif',
                      style: BaseTypography.titleMedium.toWhite,
                    ),
                    Gap.h8,
                    Text(
                      transcript.statistik.ipk,
                      style: BaseTypography.headlineLarge.toBold.toWhite,
                    ),
                    Gap.h8,
                    Text(
                      transcript.statistik.predikat,
                      style: BaseTypography.bodyLarge.toWhite,
                    ),
                    Gap.h16,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Total SKS',
                              style: BaseTypography.bodyMedium.toWhite,
                            ),
                            Gap.h4,
                            Text(
                              '${transcript.statistik.totalSKS}',
                              style: BaseTypography.headlineSmall.toBold.toWhite,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Mata Kuliah',
                              style: BaseTypography.bodyMedium.toWhite,
                            ),
                            Gap.h4,
                            Text(
                              '${transcript.statistik.totalMataKuliah}',
                              style: BaseTypography.headlineSmall.toBold.toWhite,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Gap.h24,
              
              // Daftar Mata Kuliah
              Text(
                'Daftar Mata Kuliah',
                style: BaseTypography.titleLarge.toBold,
              ),
              Gap.h16,
              
              // Group by academic year
              ...() {
                // Group transkrip by academic year
                final Map<String, List<dynamic>> academicYearGroups = {};
                for (var item in transcript.transkrip) {
                  if (!academicYearGroups.containsKey(item.academicYear)) {
                    academicYearGroups[item.academicYear] = [];
                  }
                  academicYearGroups[item.academicYear]!.add(item);
                }
                
                return academicYearGroups.entries.map((entry) {
                  final academicYear = entry.key;
                  final items = entry.value;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Academic Year Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(BaseSize.w12),
                        decoration: BoxDecoration(
                          color: BaseColor.primaryInspire.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                        ),
                        child: Text(
                          academicYear,
                          style: BaseTypography.titleMedium.toBold,
                        ),
                      ),
                      Gap.h12,
                      
                      // Mata Kuliah List
                      ...items.map((mk) {
                        return Container(
                          margin: EdgeInsets.only(bottom: BaseSize.h8),
                          padding: EdgeInsets.all(BaseSize.w12),
                          decoration: BoxDecoration(
                            color: BaseColor.white,
                            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                            border: Border.all(color: BaseColor.grey.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mk.matakuliah,
                                      style: BaseTypography.bodyLarge.toBold,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Gap.h4,
                                    Text(
                                      mk.kode,
                                      style: BaseTypography.bodySmall
                                          .copyWith(color: BaseColor.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Gap.w12,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: BaseSize.w12,
                                      vertical: BaseSize.h4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getGradeColor(mk.nilaiHuruf),
                                      borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                                    ),
                                    child: Text(
                                      mk.nilaiHuruf,
                                      style: BaseTypography.titleMedium.toBold.toWhite,
                                    ),
                                  ),
                                  Gap.h4,
                                  Text(
                                    '${mk.sks} SKS',
                                    style: BaseTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      Gap.h24,
                    ],
                  );
                }).toList();
              }(),
            ],
          ),
        ),
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Gagal memuat transkrip',
                style: BaseTypography.titleMedium,
              ),
              Gap.h8,
              Text(
                message,
                style: BaseTypography.bodyMedium.copyWith(color: BaseColor.red),
                textAlign: TextAlign.center,
              ),
              Gap.h16,
              ElevatedButton(
                onPressed: () {
                  ref.read(transcriptControllerProvider.notifier).loadTranscript();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return BaseColor.green;
      case 'B':
        return BaseColor.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'E':
        return BaseColor.red;
      default:
        return BaseColor.grey;
    }
  }

  Future<void> _handleViewHtml(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              Gap.h16,
              Container(
                padding: EdgeInsets.all(BaseSize.w16),
                decoration: BoxDecoration(
                  color: BaseColor.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                ),
                child: Text(
                  'Memuat transkrip HTML...',
                  style: BaseTypography.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );

      // Download HTML
      final htmlContent = await ref
          .read(transcriptControllerProvider.notifier)
          .downloadHtml();

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show HTML preview
      if (context.mounted) {
        _showHtmlPreview(context, htmlContent);
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat transkrip: $e'),
            backgroundColor: BaseColor.red,
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: BaseColor.white,
              onPressed: () => _handleViewHtml(context),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleDownload(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              Gap.h16,
              Container(
                padding: EdgeInsets.all(BaseSize.w16),
                decoration: BoxDecoration(
                  color: BaseColor.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                ),
                child: Text(
                  'Mengunduh transkrip...',
                  style: BaseTypography.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );

      // Download HTML
      final htmlContent = await ref
          .read(transcriptControllerProvider.notifier)
          .downloadHtml();

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/transkrip_$timestamp.html');
      await file.writeAsString(htmlContent);

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show success dialog with options
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: BaseColor.green),
                Gap.w12,
                const Text('Berhasil'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transkrip berhasil didownload!',
                  style: BaseTypography.bodyLarge,
                ),
                Gap.h8,
                Text(
                  'File disimpan di:',
                  style: BaseTypography.bodySmall.toGrey,
                ),
                Gap.h4,
                Container(
                  padding: EdgeInsets.all(BaseSize.w8),
                  decoration: BoxDecoration(
                    color: BaseColor.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                  child: Text(
                    file.path,
                    style: BaseTypography.bodySmall.copyWith(
                      fontFamily: 'monospace',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showHtmlPreview(context, htmlContent);
                },
                child: const Text('Preview'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BaseColor.primaryInspire,
                  foregroundColor: BaseColor.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal download transkrip: $e'),
            backgroundColor: BaseColor.red,
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: BaseColor.white,
              onPressed: () => _handleDownload(context),
            ),
          ),
        );
      }
    }
  }

  void _showHtmlPreview(BuildContext context, String htmlContent) {
    bool showRawHtml = false;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => Container(
            decoration: BoxDecoration(
              color: BaseColor.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(BaseSize.radiusXl),
                topRight: Radius.circular(BaseSize.radiusXl),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.symmetric(vertical: BaseSize.h12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: BaseColor.grey.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title and actions
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preview Transkrip',
                        style: BaseTypography.titleLarge.toBold,
                      ),
                      Row(
                        children: [
                          // Toggle button
                          IconButton(
                            icon: Icon(
                              showRawHtml ? Icons.visibility : Icons.code,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                showRawHtml = !showRawHtml;
                              });
                            },
                            tooltip: showRawHtml ? 'Lihat Rendered' : 'Lihat Raw HTML',
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(color: BaseColor.grey.withValues(alpha: 0.3)),
                // HTML Content - Rendered or Raw
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    padding: EdgeInsets.all(BaseSize.w16),
                    child: showRawHtml
                        ? SelectableText(
                            htmlContent,
                            style: BaseTypography.bodySmall.copyWith(
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          )
                        : Html(
                            data: htmlContent,
                            style: {
                              "body": Style(
                                fontSize: FontSize(14),
                                lineHeight: LineHeight.number(1.5),
                              ),
                              "table": Style(
                                border: Border.all(color: Colors.black),
                              ),
                              "th": Style(
                                backgroundColor: const Color(0xFFF0F0F0),
                                padding: HtmlPaddings.all(8),
                                fontWeight: FontWeight.bold,
                              ),
                              "td": Style(
                                border: Border.all(color: Colors.black),
                                padding: HtmlPaddings.all(8),
                              ),
                              "h2": Style(
                                fontSize: FontSize(20),
                                fontWeight: FontWeight.bold,
                                textAlign: TextAlign.center,
                                margin: Margins.zero,
                              ),
                              "h3": Style(
                                fontSize: FontSize(16),
                                textAlign: TextAlign.center,
                                margin: Margins.symmetric(vertical: 5),
                              ),
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
