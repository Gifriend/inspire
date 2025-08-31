import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/app_routing.dart';
import 'package:inspire/features/presentation.dart';

final elearningRouting = GoRoute(
  path: '/elearning',
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

        return ElearningScreen();
      },
    ),
  ],
);
