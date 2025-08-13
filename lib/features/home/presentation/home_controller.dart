import 'package:flutter/material.dart';
import 'package:inspire/features/presentation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  late PageController _pageController;

  @override
  HomeState build() {
    _pageController = PageController(initialPage: 0);
    ref.onDispose(() => _pageController.dispose());
    return const HomeState();
  }

  PageController get pageController => _pageController;

  void navigateTo(int index) {
    // Logika ini sudah benar, tidak perlu diubah.
    // Ia akan mengganti halaman di PageView dan memperbarui state.
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }
    state = state.copyWith(selectedBottomNavIndex: index);
  }

  void setCurrentBackPressTime(DateTime value) {
    state = state.copyWith(currentBackPressTime: value);
  }
}
