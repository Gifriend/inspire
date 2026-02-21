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
      if (message == null || message.isEmpty) {
        return;
      }

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
      appBar: AppBarWidget(title: 'Presensi Mahasiswa'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FilterCard(state: state),
          Gap.h16,
          if (state.generatedCode != null) ...[
            _GeneratedCodeCard(code: state.generatedCode!),
            Gap.h16,
          ],
          Text('Daftar Mahasiswa', style: BaseTypography.titleLarge.toBold),
          Gap.h8,
          Expanded(child: _StudentsList(state: state)),
        ],
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
          DropdownButtonFormField<CourseListModel>(
            value: state.selectedCourse,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Pilih kelas',
            ),
            items: state.courses
                .map(
                  (course) => DropdownMenuItem<CourseListModel>(
                    value: course,
                    child: Text(
                      '${course.kode} - ${course.mataKuliah?.name ?? course.nama}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: state.isLoadingCourses
                ? null
                : (value) => controller.selectCourse(value),
          ),
          Gap.h12,
          Text('Pertemuan', style: BaseTypography.titleMedium.toBold),
          Gap.h8,
          DropdownButtonFormField<int>(
            value: state.selectedMeetingNumber,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Pilih pertemuan',
            ),
            items: List.generate(
              16,
              (index) => DropdownMenuItem<int>(
                value: index + 1,
                child: Text('Pertemuan ${index + 1}'),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                controller.selectMeetingNumber(value);
              }
            },
          ),
          Gap.h12,
          ButtonWidget.primary(
            text: state.isGeneratingCode
                ? 'Memproses...'
                : 'Generate Kode Presensi',
            onTap: state.isGeneratingCode
                ? null
                : controller.generateMeetingCode,
          ),
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
            'Kode Presensi Pertemuan',
            style: BaseTypography.titleMedium.toBold,
          ),
          Gap.h8,
          Text(code, style: BaseTypography.headlineLarge.toBold),
        ],
      ),
    );
  }
}

class _StudentsList extends ConsumerWidget {
  const _StudentsList({required this.state});

  final PresensiLecturerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoadingCourses || state.isLoadingStudents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.courses.isEmpty) {
      return const Center(child: Text('Anda belum memiliki kelas yang diampu'));
    }

    if (state.students.isEmpty) {
      return const Center(child: Text('Tidak ada mahasiswa pada kelas ini'));
    }

    final controller = ref.read(presensiLecturerControllerProvider.notifier);

    return ListView.separated(
      itemCount: state.students.length,
      separatorBuilder: (_, __) => Gap.h8,
      itemBuilder: (context, index) {
        final student = state.students[index];
        final isPresent = state.manualPresentStudentIds.contains(student.id);

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
              ButtonWidget.outlined(
                text: isPresent ? 'Sudah Presensi' : 'Presensi Manual',
                onTap: isPresent || state.isSubmittingManual
                    ? null
                    : () => controller.markManualAttendance(student),
                isShrink: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
