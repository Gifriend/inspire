import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/app_routing.dart';
import 'package:inspire/features/presentation.dart';

// SOLUSI 1: Path relatif yang benar (RECOMMENDED)
final presensiRouting = GoRoute(
  path: '/presensi',
  name: AppRoute.presensi,
  builder: (context, state) => const PresensiScreen(),
  routes: [
    GoRoute(
      path: 'detail', // Tanpa '/' di awal untuk nested route
      name: AppRoute.presensiDetail,
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
    path: '/presensi',
    name: AppRoute.presensi,
    builder: (context, state) => const PresensiScreen(),
  ),
  GoRoute(
    path: '/presensi-detail', // Path terpisah
    name: AppRoute.presensiDetail,
    builder: (context, state) {
      final params = (state.extra as RouteParam?)?.params;
      final type = params?[RouteParamKey.presensiType] as PresensiType?;

      assert(type != null, 'RouteParamKey.presensiType cannot be null');

      return PresensiDetailScreen(type: type!);
    },
  ),
];
