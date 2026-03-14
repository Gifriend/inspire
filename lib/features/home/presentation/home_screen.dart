import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/services/network_status_service.dart';
import 'package:inspire/features/presentation.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ProviderSubscription<AsyncValue<bool>>? _networkStatusSubscription;
  bool? _lastNetworkStatus;

  bool _isLecturerRole(String role) {
    final normalizedRole = role.trim().toUpperCase();
    return normalizedRole == 'DOSEN' ||
        normalizedRole == 'KOORPRODI' ||
        normalizedRole == 'LECTURER';
  }

  @override
  void initState() {
    super.initState();

    _networkStatusSubscription = ref.listenManual<AsyncValue<bool>>(
      networkStatusProvider,
      (_, next) {
        next.whenData(_handleNetworkStatusChange);
      },
    );

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
  void dispose() {
    _networkStatusSubscription?.close();
    super.dispose();
  }

  void _handleNetworkStatusChange(bool isOnline) {
    if (!mounted) {
      return;
    }

    if (_lastNetworkStatus == null) {
      _lastNetworkStatus = isOnline;
      if (!isOnline) {
        _showOfflineSnackbar();
      }
      return;
    }

    if (_lastNetworkStatus == isOnline) {
      return;
    }

    _lastNetworkStatus = isOnline;

    if (isOnline) {
      _showOnlineSnackbar();
      _refreshDataAfterReconnect();
    } else {
      _showOfflineSnackbar();
    }
  }

  void _refreshDataAfterReconnect() {
    ref.read(profileControllerProvider.notifier).loadProfile(forceRefresh: true);
    ref.invalidate(announcementControllerProvider);
    ref.invalidate(scheduleControllerProvider);
  }

  void _showOfflineSnackbar() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Anda sedang offline'),
          duration: Duration(days: 1),
        ),
      );
  }

  void _showOnlineSnackbar() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Anda kembali online'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(homeControllerProvider.notifier);
    final state = ref.watch(homeControllerProvider);
    final profileState = ref.watch(profileControllerProvider);

    // PENTING: Tunggu profile selesai dimuat sebelum render dashboard
    return profileState.when(
      initial: () => _buildLoadingSkeleton(context, state),
      loading: () => _buildLoadingSkeleton(context, state),
      error: (message) => _buildErrorScreen(message),
      loaded: (user) {
        // Determine user role setelah profile berhasil dimuat
        final bool isLecturer = _isLecturerRole(user.role);

        return _buildMainContent(
          context: context,
          controller: controller,
          state: state,
          isLecturer: isLecturer,
        );
      },
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context, dynamic state) {
    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      disablePadding: true,
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDashboardHeaderSkeleton(context),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
                    child: Transform.translate(
                      offset: Offset(0, BaseSize.h12),
                      child: _buildDashboardMenuSkeleton(),
                    ),
                  ),
                  Gap.h24,
                  _buildAnnouncementSkeleton(),
                  Gap.h72,
                ],
              ),
            ),
          ),
          if (state.selectedBottomNavIndex != 4)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
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
                    onPressedItem: (_) {},
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDashboardHeaderSkeleton(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2.75,
      width: double.infinity,
      padding: EdgeInsets.all(BaseSize.w20),
      decoration: BoxDecoration(
        color: BaseColor.primaryInspire,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(BaseSize.radiusXl),
          bottomRight: Radius.circular(BaseSize.radiusXl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SkeletonLoading(height: 18, width: 120, borderRadius: 10),
          Gap.h12,
          const SkeletonLoading(height: 28, width: 220, borderRadius: 12),
          Gap.h12,
          const SkeletonLoading(height: 16, width: 180, borderRadius: 10),
        ],
      ),
    );
  }

  Widget _buildDashboardMenuSkeleton() {
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: BaseSize.w12,
          mainAxisSpacing: BaseSize.h12,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (_, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SkeletonLoading(height: 48, width: 48, borderRadius: 14),
              Gap.h8,
              const SkeletonLoading(height: 10, width: 46, borderRadius: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementSkeleton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoading(height: 20, width: 170, borderRadius: 10),
          Gap.h12,
          const SkeletonLoading(height: 120, borderRadius: 14),
        ],
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
            Gap.h16,
            Text('Error: $message'),
            Gap.h16,
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
