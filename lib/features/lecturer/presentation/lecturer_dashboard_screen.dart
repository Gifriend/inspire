import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/app_routing.dart';
import 'package:inspire/features/profile/presentation/profile_controller.dart';
import 'package:inspire/features/profile/presentation/profile_state.dart';
import 'lecturer_dashboard_controller.dart';
import 'lecturer_dashboard_state.dart';
import 'widgets/widgets.dart';

class LecturerDashboardScreen extends ConsumerStatefulWidget {
  const LecturerDashboardScreen({super.key});

  @override
  ConsumerState<LecturerDashboardScreen> createState() =>
      _LecturerDashboardScreenState();
}

class _LecturerDashboardScreenState
    extends ConsumerState<LecturerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lecturerDashboardControllerProvider.notifier).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(lecturerDashboardControllerProvider);
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: BaseColor.neutral[10],
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(lecturerDashboardControllerProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            // Show header if profile loaded
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  return profileState.maybeWhen(
                    loaded: (user) => DashboardHeader(user: user),
                    orElse: () => const SizedBox(),
                  );
                },
              ),
            ),

            // Content 
            SliverToBoxAdapter(
              child: _buildContent(dashboardState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(LecturerDashboardState state) {
    if (state is LecturerDashboardInitial || state is LecturerDashboardLoading) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is LecturerDashboardError) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Error: ${state.message}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: BaseColor.primaryText.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(lecturerDashboardControllerProvider.notifier)
                      .refresh();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is LecturerDashboardLoaded) {
      final data = state.data;
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                      // Quick Stats
                      const Text(
                        'Statistik',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BaseColor.primaryText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                        children: [
                          QuickStatsCard(
                            title: 'Total Kelas',
                            value: data.totalClasses.toString(),
                            icon: Icons.class_,
                            color: Colors.blue,
                          ),
                          QuickStatsCard(
                            title: 'Total Mahasiswa',
                            value: data.totalStudents.toString(),
                            icon: Icons.people,
                            color: Colors.green,
                          ),
                          QuickStatsCard(
                            title: 'KRS Pending',
                            value: data.pendingKrs.toString(),
                            icon: Icons.pending_actions,
                            color: Colors.orange,
                            subtitle: data.pendingKrs > 0 ? 'Perlu Review' : null,
                          ),
                          QuickStatsCard(
                            title: 'Presensi Hari Ini',
                            value: data.todayPresence.toString(),
                            icon: Icons.check_circle,
                            color: Colors.purple,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Menu Cards
                      const Text(
                        'Menu Utama',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BaseColor.primaryText,
                        ),
                      ),
                      const SizedBox(height: 12),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio:0.9,
                        children: [
                          DashboardMenuCard(
                            title: 'Persetujuan KRS',
                            subtitle: 'Review dan setujui KRS mahasiswa',
                            icon: Icons.assignment_turned_in,
                            color: Colors.blue,
                            badgeCount: data.pendingKrs,
                            onTap: () {
                              // Navigate to KRS Lecturer
                              context.pushNamed(AppRoute.krsLecturer);
                            },
                          ),
                          DashboardMenuCard(
                            title: 'Presensi',
                            subtitle: 'Kelola presensi mahasiswa',
                            icon: Icons.how_to_reg,
                            color: Colors.green,
                            onTap: () {
                              // Navigate to Presensi Lecturer
                              context.pushNamed(AppRoute.presensiLecturer);
                            },
                          ),
                          DashboardMenuCard(
                            title: 'E-Learning',
                            subtitle: 'Materi, tugas, dan kuis',
                            icon: Icons.school,
                            color: Colors.purple,
                            onTap: () {
                              // Navigate to E-Learning Lecturer
                              context.pushNamed(AppRoute.eLearningLecturer);
                            },
                          ),
                          DashboardMenuCard(
                            title: 'Pengumuman',
                            subtitle: 'Buat dan kelola pengumuman',
                            icon: Icons.campaign,
                            color: Colors.orange,
                            onTap: () {
                              // Navigate to Announcement Lecturer
                              context.pushNamed(AppRoute.announcementLecturer);
                            },
                          ),
                          DashboardMenuCard(
                            title: 'Penilaian',
                            subtitle: 'Input dan kelola nilai',
                            icon: Icons.grade,
                            color: Colors.red,
                            onTap: () {
                              // Navigate to Grading
                              context.pushNamed(AppRoute.gradingLecturer);
                            },
                          ),
                          DashboardMenuCard(
                            title: 'Kelas Saya',
                            subtitle: 'Lihat semua kelas yang diampu',
                            icon: Icons.people_outline,
                            color: Colors.teal,
                            onTap: () {
                              // Navigate to My Classes
                              context.pushNamed(AppRoute.myClassesLecturer);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Recent Activities
                      const Text(
                        'Aktivitas Terbaru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BaseColor.primaryText,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (data.recentActivities.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 48,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Belum ada aktivitas',
                                  style: TextStyle(
                                    color: BaseColor.primaryText
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...data.recentActivities.map(
                          (activity) => RecentActivityCard(activity: activity),
                        ).toList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }

    return const SizedBox();
  }
}
