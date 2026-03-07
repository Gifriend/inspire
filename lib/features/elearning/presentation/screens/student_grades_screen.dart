import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/elearning/student_grades_model.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'package:jiffy/jiffy.dart';

class StudentGradesScreen extends ConsumerStatefulWidget {
  final int kelasId;
  final String namaKelas;

  const StudentGradesScreen({
    super.key,
    required this.kelasId,
    required this.namaKelas,
  });

  @override
  ConsumerState<StudentGradesScreen> createState() =>
      _StudentGradesScreenState();
}

class _StudentGradesScreenState extends ConsumerState<StudentGradesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(studentGradesControllerProvider(widget.kelasId).notifier)
          .loadStudentGrades();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      studentGradesControllerProvider(widget.kelasId),
    );

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: 'Nilai & Ranking',
        leadIcon: Assets.icons.fill.arrowBack,
        onPressedLeadIcon: () => context.pop(),
      ),
      disableSingleChildScrollView: true,
      disablePadding: true,
      child: state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        loaded: (data) => SingleChildScrollView(
          child: Column(
            children: [
              // Header Card with Grades Summary
              _buildHeaderCard(data),

              // Tab Navigation
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Tugas (${data.detailTugas.length})'),
                    Tab(text: 'Kuis (${data.detailKuis.length})'),
                  ],
                ),
              ),

              // Tab Content
              SizedBox(
                height: MediaQuery.of(context).size.height - 320,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Assignments Tab
                    _buildAssignmentsTab(data),
                    // Quizzes Tab
                    _buildQuizzesTab(data),
                  ],
                ),
              ),
            ],
          ),
        ),
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: BaseColor.red),
              Gap.h16,
              Text(
                'Gagal memuat nilai',
                style: BaseTypography.titleMedium.toBold,
              ),
              Gap.h8,
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(StudentGradesData data) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [BaseColor.primaryInspire, BaseColor.primaryInspire.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Info
          Text(
            data.namaKelas,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${data.kodeMK} - ${data.namaMK}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Dosen: ${data.dosenNama}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 20),

          // Grade Summary Boxes
          Row(
            children: [
              Expanded(
                child: _buildGradeBox(
                  'Total Nilai',
                  data.totalNilai.toStringAsFixed(2),
                  BaseColor.success,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildGradeBox(
                  'Peringkat',
                  '${data.peringkat}',
                  BaseColor.warning,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildGradeBox(
                  'Dari',
                  '${data.totalPeserta}',
                  BaseColor.info,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Weight Info
          if (data.catatan != null)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange.shade700, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      data.catatan!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade700, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Total bobot ${data.totalBobot}% (Valid)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGradeBox(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsTab(StudentGradesData data) {
    if (data.detailTugas.isEmpty) {
      return Center(
        child: Text('Belum ada tugas'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: data.detailTugas.length,
      itemBuilder: (context, index) {
        final task = data.detailTugas[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(color: BaseColor.cardBackground2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        task.kategori,
                        style: TextStyle(fontSize: 11),
                      ),
                      backgroundColor: BaseColor.primaryLight,
                      labelStyle: TextStyle(color: BaseColor.primaryInspire),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Bobot: ${task.bobot}%',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Deadline: ${Jiffy.parse(task.deadline.toString()).format(pattern: 'dd MMM yyyy HH:mm')}',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: _buildGradeStatus(task.nilai, task.submitted),
          ),
        );
      },
    );
  }

  Widget _buildQuizzesTab(StudentGradesData data) {
    if (data.detailKuis.isEmpty) {
      return Center(
        child: Text('Belum ada kuis'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: data.detailKuis.length,
      itemBuilder: (context, index) {
        final quiz = data.detailKuis[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(color: BaseColor.cardBackground2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            title: Text(
              quiz.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        quiz.kategori,
                        style: TextStyle(fontSize: 11),
                      ),
                      backgroundColor: BaseColor.primaryLight,
                      labelStyle: TextStyle(color: BaseColor.info),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Bobot: ${quiz.bobot}%',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Max: ${quiz.maxPoints.toStringAsFixed(0)} poin',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: _buildQuizStatus(
              quiz.scorePercentage,
              quiz.attempted,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradeStatus(double? nilai, bool submitted) {
    if (!submitted) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: BaseColor.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Belum',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: BaseColor.red,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: BaseColor.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        nilai?.toStringAsFixed(1) ?? '-',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: BaseColor.success,
        ),
      ),
    );
  }

  Widget _buildQuizStatus(double? percentage, bool attempted) {
    if (!attempted) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: BaseColor.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Belum',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: BaseColor.red,
          ),
        ),
      );
    }

    final percent = percentage ?? 0;
    final color = percent >= 70
        ? BaseColor.success
        : percent >= 50
            ? BaseColor.warning
            : BaseColor.red;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${percent.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
