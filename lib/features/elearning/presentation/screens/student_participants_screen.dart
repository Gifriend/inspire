import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/elearning/student_participants_model.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';

class StudentParticipantsScreen extends ConsumerStatefulWidget {
  final int kelasId;
  final String namaKelas;

  const StudentParticipantsScreen({
    super.key,
    required this.kelasId,
    required this.namaKelas,
  });

  @override
  ConsumerState<StudentParticipantsScreen> createState() =>
      _StudentParticipantsScreenState();
}

class _StudentParticipantsScreenState
    extends ConsumerState<StudentParticipantsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(studentParticipantsControllerProvider(widget.kelasId).notifier)
          .loadStudentParticipants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      studentParticipantsControllerProvider(widget.kelasId),
    );

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: 'Peserta Kelas',
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
          child: Padding(
            padding: EdgeInsets.all(BaseSize.w16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap.h8,
                // Header Card
                _buildHeaderCard(data),
                Gap.h24,

                // List Title
                Text(
                  'Daftar Peserta (${data.totalPeserta})',
                  style: BaseTypography.titleMedium.toBold,
                ),
                Gap.h12,

                // Participants List
                ..._buildParticipantsList(data),
                Gap.h32,
              ],
            ),
          ),
        ),
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: BaseColor.red),
              Gap.h16,
              Text(
                'Gagal memuat peserta',
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

  Widget _buildHeaderCard(StudentParticipantsData data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [BaseColor.primaryInspire, BaseColor.primaryInspire.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.namaKelas,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${data.kodeMK} - ${data.namaMK}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'SKS: ${data.sks}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 16),
            Divider(color: Colors.white24, height: 1),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dosen Pengampu',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        data.dosen.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Peserta',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${data.totalPeserta} mahasiswa',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticipantsList(StudentParticipantsData data) {
    return List.generate(
      data.peserta.length,
      (index) {
        final participant = data.peserta[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(color: BaseColor.cardBackground2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: participant.photo != null
                  ? NetworkImage(participant.photo!)
                  : null,
              backgroundColor: BaseColor.primaryLight,
              child: participant.photo == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              participant.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'NIM: ${participant.nim ?? '-'}',
              style: TextStyle(fontSize: 12),
            ),
            trailing: Icon(Icons.person, color: BaseColor.success, size: 20),
          ),
        );
      },
    );
  }
}
