import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/features/presentation.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLecturerRole(String role) {
    final normalizedRole = role.trim().toUpperCase();
    return normalizedRole == 'DOSEN' ||
        normalizedRole == 'KOORPRODI' ||
        normalizedRole == 'LECTURER';
  }

  @override
  void initState() {
    super.initState();
    // Load profile saat HomeScreen pertama kali dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentProfileState = ref.read(profileControllerProvider);

      // Load profile jika belum loaded
      final bool shouldLoadProfile = currentProfileState.maybeWhen(
        loaded: (_) => false,
        orElse: () => true,
      );

      if (shouldLoadProfile) {
        ref.read(profileControllerProvider.notifier).loadProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(homeControllerProvider.notifier);
    final state = ref.watch(homeControllerProvider);
    final profileState = ref.watch(profileControllerProvider);

    // PENTING: Tunggu profile selesai dimuat sebelum render dashboard
    return profileState.when(
      initial: () => _buildLoadingScreen(),
      loading: () => _buildLoadingScreen(),
      error: (message) => _buildErrorScreen(message),
      loaded: (user) {
        // Determine user role setelah profile berhasil dimuat
        final bool isLecturer = _isLecturerRole(user.role);

        if (kDebugMode) {
          print(
            '🔍 HomeScreen - User: ${user.name}, Role: ${user.role}, isLecturer: $isLecturer',
          );
        }

        return _buildMainContent(
          context: context,
          controller: controller,
          state: state,
          isLecturer: isLecturer,
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat profil...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $message'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(profileControllerProvider.notifier).loadProfile();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent({
    required BuildContext context,
    required dynamic controller,
    required dynamic state,
    required bool isLecturer,
  }) {
    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      disablePadding: true,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, _) {
          if (state.selectedBottomNavIndex != 0) {
            controller.navigateTo(0);
          } else {
            DateTime now = DateTime.now();

            if (state.currentBackPressTime == null ||
                now.difference(state.currentBackPressTime!) >
                    const Duration(seconds: 2)) {
              controller.setCurrentBackPressTime(now);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tekan sekali lagi untuk keluar',
                    style: BaseTypography.titleMedium,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              Navigator.of(context).pop();
            }
          }
        },
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: PageView(
                allowImplicitScrolling: false,
                physics: const NeverScrollableScrollPhysics(),
                controller: controller.pageController,
                children: [
                  // Tab pertama: Tampilkan LecturerDashboard untuk dosen, Dashboard biasa untuk mahasiswa
                  isLecturer
                      ? const LecturerDashboardScreen()
                      : const DashboardScreen(),
                  // Tab kedua: Presensi (disesuaikan untuk dosen atau mahasiswa)
                  isLecturer
                      ? const PresensiLecturerScreen()
                      : const PresensiScreen(),
                  // Tab ketiga: Menu Lainnya
                  const OtherMenuScreen(),
                  // Tab keempat: Profile
                  const ProfileScreen(),
                ],
              ),
            ),
            if (state.selectedBottomNavIndex != 4)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: BottomNavBar(
                    currentIndex: state.selectedBottomNavIndex,
                    onPressedItem: (index) {
                      controller.navigateTo(index);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
