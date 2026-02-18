import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/data_sources.dart';
import 'package:inspire/features/profile/presentation/profile_controller.dart';
import 'lecturer_dashboard_state.dart';

final lecturerDashboardControllerProvider = StateNotifierProvider.autoDispose<
    LecturerDashboardController, LecturerDashboardState>(
  (ref) => LecturerDashboardController(
    ref.read(dioClientProvider),
    ref,
  ),
);

class LecturerDashboardController
    extends StateNotifier<LecturerDashboardState> {
  final DioClient _dioClient;
  final Ref _ref;

  LecturerDashboardController(this._dioClient, this._ref)
      : super(const LecturerDashboardInitial());

  Future<void> loadDashboardData() async {
    state = const LecturerDashboardLoading();

    try {
      // Get current user from profile controller
      final profileController = _ref.read(profileControllerProvider.notifier);
      final user = profileController.cachedUser;
      
      if (user == null) {
        state = const LecturerDashboardError('User not logged in');
        return;
      }

      // Load all data in parallel
      final results = await Future.wait([
        _loadClasses(),
        _loadPendingKrs(),
        _loadTodayPresence(),
      ]);

      final classes = results[0] as List<ClassInfo>;
      final pendingKrs = results[1] as int;
      final todayPresence = results[2] as int;

      // Calculate total students from all classes
      final totalStudents =
          classes.fold(0, (int sum, cls) => sum + cls.studentCount);

      // Mock recent activities (replace with real API call if available)
      final activities = _generateRecentActivities();

      state = LecturerDashboardLoaded(
        DashboardData(
          totalClasses: classes.length,
          totalStudents: totalStudents,
          pendingKrs: pendingKrs,
          todayPresence: todayPresence,
          recentClasses: classes,
          recentActivities: activities,
        ),
      );
    } catch (e) {
      state = LecturerDashboardError(e.toString());
    }
  }

  Future<List<ClassInfo>> _loadClasses() async {
    try {
      // Fetch lecturer's classes from API
      // Assuming there's an endpoint to get lecturer's classes
      final response = await _dioClient.get<dynamic>('/lecturer/classes');
      
      if (response != null) {
        final data = response as Map<String, dynamic>;
        final List<dynamic> classes = data['data'] ?? [];
        return classes.map((json) => _parseClassInfo(json as Map<String, dynamic>)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Error loading classes: $e');
      return [];
    }
  }

  Future<int> _loadPendingKrs() async {
    try {
      // Fetch pending KRS count
      final response = await _dioClient.get<dynamic>('/krs/pending-count');
      
      if (response != null) {
        final data = response as Map<String, dynamic>;
        return data['data']?['count'] ?? 0;
      }
      
      return 0;
    } catch (e) {
      debugPrint('Error loading pending KRS: $e');
      return 0;
    }
  }

  Future<int> _loadTodayPresence() async {
    try {
      // Fetch today's presence count
      final response = await _dioClient.get<dynamic>('/presensi/today-count');
      
      if (response != null) {
        final data = response as Map<String, dynamic>;
        return data['data']?['count'] ?? 0;
      }
      
      return 0;
    } catch (e) {
      debugPrint('Error loading today presence: $e');
      return 0;
    }
  }

  ClassInfo _parseClassInfo(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['id'] ?? 0,
      code: json['kode'] ?? '',
      name: json['nama'] ?? '',
      schedule: json['jadwal'] ?? '',
      studentCount: json['studentCount'] ?? 0,
      courseName: json['mataKuliah']?['name'] ?? '',
      room: json['ruangan'] ?? '',
    );
  }

  List<ActivityInfo> _generateRecentActivities() {
    // This should be replaced with real API call
    return [
      ActivityInfo(
        title: 'KRS Submitted',
        description: '5 mahasiswa mengajukan KRS',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'krs',
      ),
      ActivityInfo(
        title: 'Assignment Submitted',
        description: '12 tugas dikumpulkan',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: 'submission',
      ),
      ActivityInfo(
        title: 'Announcement Posted',
        description: 'Pengumuman UTS telah dipublikasi',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        type: 'announcement',
      ),
    ];
  }

  void refresh() {
    loadDashboardData();
  }
}
