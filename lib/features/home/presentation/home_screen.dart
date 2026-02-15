import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/features/presentation.dart';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(homeControllerProvider.notifier);
    final state = ref.watch(homeControllerProvider);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      disablePadding: true,
      child: WillPopScope(
        onWillPop: () async {
          if (state.selectedBottomNavIndex != 0) {
            controller.navigateTo(0);
            return Future.value(false);
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
                ),
              );
              return Future.value(false);
            }
            return Future.value(true);
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
                  DashboardScreen(),
                  PresensiScreen(),
                  OtherMenuScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
            if (state.selectedBottomNavIndex != 4)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomNavBar(
                  currentIndex: state.selectedBottomNavIndex,
                  onPressedItem: (index) {
                    controller.navigateTo(index);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
