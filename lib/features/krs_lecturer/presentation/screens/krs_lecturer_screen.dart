import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/krs/krs_lecturer_model.dart';
import 'package:inspire/core/routing/app_routing.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/krs_lecturer/presentation/controllers/krs_lecturer_controller.dart';
import 'package:inspire/features/krs_lecturer/presentation/states/krs_lecturer_state.dart';

class KrsLecturerScreen extends ConsumerStatefulWidget {
  const KrsLecturerScreen({super.key});

  @override
  ConsumerState<KrsLecturerScreen> createState() => _KrsLecturerScreenState();
}

class _KrsLecturerScreenState extends ConsumerState<KrsLecturerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = const ['Semua', 'Diajukan', 'Disetujui', 'Ditolak'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _loadData();
  }

  void _loadData() {
    final status = _statusForTab(_tabController.index);
    ref
        .read(krsLecturerListControllerProvider.notifier)
        .loadSubmissions(status: status);
  }

  String? _statusForTab(int index) {
    switch (index) {
      case 1:
        return 'DIAJUKAN';
      case 2:
        return 'DISETUJUI';
      case 3:
        return 'DITOLAK';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(krsLecturerListControllerProvider);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'Persetujuan KRS',
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
      ),
      child: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: BaseColor.primaryInspire,
              unselectedLabelColor: Colors.grey,
              indicatorColor: BaseColor.primaryInspire,
              labelStyle: BaseTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          // Content
          Expanded(
            child: listState.when(
              initial: () => const Center(child: Text('Memuat...')),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: BaseColor.primaryInspire,
                ),
              ),
              loaded: (submissions) => submissions.isEmpty
                  ? _buildEmptyState()
                  : _buildSubmissionList(submissions),
              error: (message) => _buildErrorState(message),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          Gap.h16,
          Text(
            'Tidak ada KRS di kategori ini',
            style: BaseTypography.bodyLarge.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          Gap.h8,
          Text(
            'KRS mahasiswa bimbingan akan muncul di sini',
            style: BaseTypography.bodySmall.copyWith(
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          Gap.h16,
          Text('Gagal memuat data', style: BaseTypography.bodyLarge),
          Gap.h8,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w24),
            child: Text(
              message,
              style: BaseTypography.bodySmall.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Gap.h16,
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionList(List<KrsSubmissionModel> submissions) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: EdgeInsets.all(BaseSize.w16),
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          return _buildSubmissionCard(submissions[index]);
        },
      ),
    );
  }

  Widget _buildSubmissionCard(KrsSubmissionModel submission) {
    final statusColor = _statusColor(submission.status);
    final statusText = _statusText(submission.status);
    final studentName = submission.mahasiswa?.nama ?? 'Mahasiswa';
    final nim = submission.mahasiswa?.nim ?? '-';

    return Card(
      margin: EdgeInsets.only(bottom: BaseSize.h12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        onTap: () {
          context.pushNamed(
            AppRoute.krsLecturerDetail,
            pathParameters: {'krsId': submission.id.toString()},
          );
        },
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student info row
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        BaseColor.primaryInspire.withValues(alpha: 0.1),
                    child: Text(
                      studentName.isNotEmpty
                          ? studentName[0].toUpperCase()
                          : '?',
                      style: BaseTypography.titleMedium.copyWith(
                        color: BaseColor.primaryInspire,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Gap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: BaseTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap.h4,
                        Text(
                          'NIM: $nim',
                          style: BaseTypography.bodySmall.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: BaseTypography.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              Gap.h12,
              // KRS summary
              Container(
                padding: EdgeInsets.all(BaseSize.w12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
                child: Row(
                  children: [
                    _infoChip(
                      Icons.school_outlined,
                      '${submission.totalSKS} SKS',
                    ),
                    Gap.w16,
                    _infoChip(
                      Icons.class_outlined,
                      '${submission.matakuliah.length} MK',
                    ),
                    Gap.w16,
                    _infoChip(
                      Icons.calendar_today_outlined,
                      submission.academicYear,
                    ),
                  ],
                ),
              ),
              // Submission date
              if (submission.tanggalPengajuan != null) ...[
                Gap.h8,
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Diajukan: ${_formatDate(submission.tanggalPengajuan!)}',
                      style: BaseTypography.bodySmall.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
              // Quick action buttons for DIAJUKAN status
              if (submission.status == StatusKRS.diajukan) ...[
                Gap.h12,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(submission),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Tolak'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          textStyle: BaseTypography.bodySmall
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showApproveDialog(submission),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Setujui'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          textStyle: BaseTypography.bodySmall
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              // Cancel button for DISETUJUI status
              if (submission.status == StatusKRS.disetujui) ...[
                Gap.h12,
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(submission),
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('Batalkan Persetujuan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(color: Colors.orange.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: BaseTypography.bodySmall
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: BaseTypography.bodySmall.copyWith(
              color: Colors.grey.shade700,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _statusColor(StatusKRS status) {
    switch (status) {
      case StatusKRS.draft:
        return Colors.grey;
      case StatusKRS.diajukan:
        return Colors.orange;
      case StatusKRS.disetujui:
        return Colors.green;
      case StatusKRS.ditolak:
        return Colors.red;
    }
  }

  String _statusText(StatusKRS status) {
    switch (status) {
      case StatusKRS.draft:
        return 'Draft';
      case StatusKRS.diajukan:
        return 'Diajukan';
      case StatusKRS.disetujui:
        return 'Disetujui';
      case StatusKRS.ditolak:
        return 'Ditolak';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month]} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  // ─── Action dialogs ─────────────────────────────────────────────

  void _showApproveDialog(KrsSubmissionModel submission) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Setujui KRS?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KRS ${submission.mahasiswa?.nama ?? ''} '
              '(${submission.totalSKS} SKS, '
              '${submission.matakuliah.length} MK)',
              style: BaseTypography.bodySmall,
            ),
            Gap.h16,
            TextField(
              controller: catatanController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
                hintText: 'Mis: Disetujui',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(krsLecturerActionControllerProvider.notifier)
                  .approveKrs(
                    submission.id,
                    catatan: catatanController.text.isNotEmpty
                        ? catatanController.text
                        : null,
                  );
              if (success && mounted) {
                _showSnackBar('KRS berhasil disetujui', Colors.green);
                _loadData();
              }
            },
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(KrsSubmissionModel submission) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak KRS?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KRS ${submission.mahasiswa?.nama ?? ''} akan ditolak.',
              style: BaseTypography.bodySmall,
            ),
            Gap.h16,
            TextField(
              controller: catatanController,
              decoration: const InputDecoration(
                labelText: 'Alasan penolakan *',
                border: OutlineInputBorder(),
                hintText: 'Wajib diisi',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (catatanController.text.trim().isEmpty) {
                _showSnackBar('Alasan penolakan wajib diisi', Colors.orange);
                return;
              }
              Navigator.pop(ctx);
              final success = await ref
                  .read(krsLecturerActionControllerProvider.notifier)
                  .rejectKrs(
                    submission.id,
                    catatan: catatanController.text.trim(),
                  );
              if (success && mounted) {
                _showSnackBar('KRS berhasil ditolak', Colors.red);
                _loadData();
              }
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(KrsSubmissionModel submission) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Persetujuan?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KRS ${submission.mahasiswa?.nama ?? ''} yang sudah disetujui '
              'akan dikembalikan ke status Draft.',
              style: BaseTypography.bodySmall,
            ),
            Gap.h16,
            TextField(
              controller: catatanController,
              decoration: const InputDecoration(
                labelText: 'Alasan pembatalan *',
                border: OutlineInputBorder(),
                hintText: 'Wajib diisi',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (catatanController.text.trim().isEmpty) {
                _showSnackBar(
                    'Alasan pembatalan wajib diisi', Colors.orange);
                return;
              }
              Navigator.pop(ctx);
              final success = await ref
                  .read(krsLecturerActionControllerProvider.notifier)
                  .cancelKrs(
                    submission.id,
                    catatan: catatanController.text.trim(),
                  );
              if (success && mounted) {
                _showSnackBar(
                    'Persetujuan KRS berhasil dibatalkan', Colors.orange);
                _loadData();
              }
            },
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
