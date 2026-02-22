import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/models.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/extensions/text_style_extension.dart';
import 'package:inspire/core/widgets/widgets.dart';

import 'presensi_lecturer_controller.dart';
import 'presensi_lecturer_state.dart';

class PresensiLecturerScreen extends ConsumerStatefulWidget {
  const PresensiLecturerScreen({super.key});

  @override
  ConsumerState<PresensiLecturerScreen> createState() =>
      _PresensiLecturerScreenState();
}

class _PresensiLecturerScreenState
    extends ConsumerState<PresensiLecturerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(presensiLecturerControllerProvider.notifier).loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(presensiLecturerControllerProvider);

    ref.listen<PresensiLecturerState>(presensiLecturerControllerProvider, (
      previous,
      next,
    ) {
      final message = next.errorMessage ?? next.infoMessage;
      if (message == null || message.isEmpty) return;

      final isError = next.errorMessage != null;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? BaseColor.red : BaseColor.primaryInspire,
          ),
        );

      ref.read(presensiLecturerControllerProvider.notifier).clearMessage();
    });

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(title: 'Presensi Dosen'),
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FilterCard(state: state),
            Gap.h16,
            if (state.generatedCode != null) ...[
              _GeneratedCodeCard(code: state.generatedCode!),
              Gap.h16,
            ],

            // Sub-menu for lecturer actions
            TabBar(
              labelColor: BaseColor.primaryInspire,
              unselectedLabelColor: BaseColor.grey,
              indicatorColor: BaseColor.primaryInspire,
              tabs: const [
                Tab(text: 'Presensi Manual'),
                Tab(text: 'Daftar Kehadiran'),
              ],
            ),
            Gap.h8,

            Expanded(
              child: TabBarView(
                children: [
                  _StudentsList(state: state, viewMode: _ListViewMode.manual),
                  _StudentsList(
                    state: state,
                    viewMode: _ListViewMode.attendance,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterCard extends ConsumerWidget {
  const _FilterCard({required this.state});
  final PresensiLecturerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(presensiLecturerControllerProvider.notifier);
    final hasSession = state.currentSessionId != null;

    // Helper formatter untuk UI
    final dateText = state.selectedDeadlineDate != null
        ? '${state.selectedDeadlineDate!.day}/${state.selectedDeadlineDate!.month}/${state.selectedDeadlineDate!.year}'
        : 'Pilih Tanggal';

    final timeText = state.selectedDeadlineTime != null
        ? '${state.selectedDeadlineTime!.hour.toString().padLeft(2, '0')}:${state.selectedDeadlineTime!.minute.toString().padLeft(2, '0')}'
        : 'Pilih Jam';

    return Container(
      padding: EdgeInsets.all(BaseSize.h12),
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        boxShadow: [
          BoxShadow(
            color: BaseColor.grey.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kelas', style: BaseTypography.titleMedium.toBold),
          Gap.h8,
          DropdownWidget<CourseListModel>(
            hintText: 'Pilih kelas',
            isLoading: state.isLoadingCourses,
            items: state.courses,
            value: state.selectedCourse,
            itemLabelBuilder: (course) =>
                '${course.kode} - ${course.mataKuliah?.name ?? course.nama}',
            onChanged: (value) => controller.selectCourse(value),
          ),
          Gap.h12,
          Text('Pertemuan', style: BaseTypography.titleMedium.toBold),
          Gap.h8,
          DropdownWidget<int>(
            hintText: 'Pilih pertemuan',
            items: List.generate(16, (index) => index + 1),
            value: state.selectedMeetingNumber,
            itemLabelBuilder: (item) => 'Pertemuan $item',
            onChanged: (value) {
              if (value != null) controller.selectMeetingNumber(value);
            },
          ),
          Gap.h12,

          // Generate button only shows if session doesn't exist
          if (!hasSession && state.selectedCourse != null) ...[
            Gap.h12,
            Text(
              'Batas Waktu Presensi (Opsional)',
              style: BaseTypography.titleMedium.toBold,
            ),
            Gap.h8,
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate:
                            DateTime.now(), // Cegah pilih tanggal kemarin
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) controller.selectDeadlineDate(picked);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w12,
                        vertical: BaseSize.h12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: BaseColor.grey),
                        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dateText, style: BaseTypography.bodyMedium),
                          Icon(
                            Icons.calendar_today,
                            size: BaseSize.w16,
                            color: BaseColor.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) controller.selectDeadlineTime(picked);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w12,
                        vertical: BaseSize.h12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: BaseColor.grey),
                        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(timeText, style: BaseTypography.bodyMedium),
                          Icon(
                            Icons.access_time,
                            size: BaseSize.w16,
                            color: BaseColor.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Tombol Reset jika ada isian deadline
            if (state.selectedDeadlineDate != null ||
                state.selectedDeadlineTime != null) ...[
              Gap.h4,
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => controller.clearDeadline(),
                  child: const Text('Hapus Batas Waktu'),
                ),
              ),
            ],

            Gap.h16,
            ButtonWidget.primary(
              color: BaseColor.primaryInspire,
              text: state.isGeneratingCode
                  ? 'Memproses...'
                  : 'Generate Kode Presensi',
              onTap: state.isGeneratingCode || state.isLoadingStudents
                  ? null
                  : controller.generateMeetingCode,
            ),
          ],
        ],
      ),
    );
  }
}

class _GeneratedCodeCard extends StatelessWidget {
  const _GeneratedCodeCard({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSize.h12),
      decoration: BoxDecoration(
        color: BaseColor.primaryInspire.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kode Presensi Sesi Aktif',
            style: BaseTypography.titleMedium.toBold,
          ),
          Gap.h8,
          Text(code, style: BaseTypography.headlineLarge.toBold),
        ],
      ),
    );
  }
}

enum _ListViewMode { manual, attendance }

class _StudentsList extends ConsumerWidget {
  const _StudentsList({required this.state, required this.viewMode});

  final PresensiLecturerState state;
  final _ListViewMode viewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoadingStudents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.currentSessionId == null && viewMode == _ListViewMode.manual) {
      return const Center(
        child: Text('Generate sesi presensi terlebih dahulu.'),
      );
    }

    // Filter students based on active tab
    final displayStudents = state.students.where((student) {
      final isAttended = state.attendedStudentIds.contains(student.id);
      return viewMode == _ListViewMode.attendance ? isAttended : !isAttended;
    }).toList();

    if (displayStudents.isEmpty) {
      final emptyText = viewMode == _ListViewMode.attendance
          ? 'Belum ada mahasiswa yang presensi.'
          : 'Semua mahasiswa telah presensi.';
      return Center(child: Text(emptyText));
    }

    final controller = ref.read(presensiLecturerControllerProvider.notifier);

    return ListView.separated(
      itemCount: displayStudents.length,
      separatorBuilder: (_, _) => Gap.h8,
      itemBuilder: (context, index) {
        final student = displayStudents[index];

        return Container(
          padding: EdgeInsets.all(BaseSize.h12),
          decoration: BoxDecoration(
            color: BaseColor.white,
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
            boxShadow: [
              BoxShadow(
                color: BaseColor.grey.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: BaseColor.primaryInspire.withValues(
                  alpha: 0.12,
                ),
                child: Text(
                  student.name.isNotEmpty ? student.name[0].toUpperCase() : '-',
                  style: BaseTypography.titleMedium.toBold,
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: BaseTypography.titleMedium.toBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.h4,
                    Text(
                      'NIM: ${student.nim}',
                      style: BaseTypography.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Dynamic button based on current tab mode
              if (viewMode == _ListViewMode.manual)
                ButtonWidget.outlined(
                  buttonSize: ButtonSize.small,
                  text: 'Presensi Manual',
                  useAutoSizeText: true,
                  onTap: state.isSubmittingManual
                      ? null
                      : () => controller.markManualAttendance(student),
                  isShrink: true,
                )
              else
                ButtonWidget.outlined(
                  buttonSize: ButtonSize.small,
                  text: 'Batalkan',
                  textColor: BaseColor.red,
                  // borderColor: BaseColor.red,
                  useAutoSizeText: true,
                  onTap: state.isSubmittingManual
                      ? null
                      : () => controller.revokeAttendance(student),
                  isShrink: true,
                ),
            ],
          ),
        );
      },
    );
  }
}
