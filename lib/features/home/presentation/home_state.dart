class HomeState {
  final int selectedBottomNavIndex;
  final DateTime? currentBackPressTime;

  const HomeState({this.selectedBottomNavIndex = 0, this.currentBackPressTime});

  HomeState copyWith({
    int? selectedBottomNavIndex,
    DateTime? currentBackPressTime,
  }) {
    return HomeState(
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
      currentBackPressTime: currentBackPressTime ?? this.currentBackPressTime,
    );
  }
}
