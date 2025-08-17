import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/app_routing.dart';
import 'package:inspire/features/presentation.dart';

final PresensiRouting = GoRoute(
  path: '/publishing',
  name: AppRoute.presensi,
  builder: (context, state) => const PresensiScreen(),
  routes: [
    GoRoute(
      path: 'presensi-detail',
      name: AppRoute.presensiDetail,
      builder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final type = params?[RouteParamKey.presensiType] as PresensiType?;

        assert(type != null, 'RouteParamKey.activityType cannot be null');

        return PresensiDetailScreen(type: type!);
      },
    ),
    // GoRoute(
    //   path: 'map',
    //   name: AppRoute.publishingMap,
    //   builder: (context, state) {
    //     final params = (state.extra as RouteParam?)?.params;
    //     final ot = params?[RouteParamKey.mapOperationType] as MapOperationType?;
    //
    //     assert(ot != null, 'RouteParamKey.mapOperationType cannot be null');
    //
    //     return MapScreen(mapOperationType: ot!);
    //   },
    // ),
  ],
);
