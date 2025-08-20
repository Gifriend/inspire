import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/app_routing.dart';
import 'package:inspire/features/presentation.dart';

final presensiRouting = GoRoute(
  path: '/presensi',
  name: AppRoute.eLearning,
  builder: (context, state) => const ElearningScreen(),
  routes: [
    GoRoute(
      path: 'elearning_search', // Tanpa '/' di awal untuk nested route
      name: AppRoute.eLearning,
      builder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final type = params?[RouteParamKey.presensiType] as PresensiType?;

        assert(type != null, 'RouteParamKey.presensiType cannot be null');

        return PresensiDetailScreen(type: type!);
      },
    ),
  ],
);

// SOLUSI 2: Flat structure (Alternative)
final presensiRoutingFlat = [
  GoRoute(
    path: '/elearning',
    name: AppRoute.eLearning,
    builder: (context, state) => const ElearningScreen(),
  ),
  GoRoute(
    path: '/elearning-search', // Path terpisah
    name: AppRoute.eLearningSearch,
    builder: (context, state) {
      final params = (state.extra as RouteParam?)?.params;
      final type = params?[RouteParamKey.presensiType] as PresensiType?;

      assert(type != null, 'RouteParamKey.presensiType cannot be null');

      return PresensiDetailScreen(type: type!);
    },
  ),
];
