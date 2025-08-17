import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presensi/presentation/widgets/widgets.dart';

class PresensiScreen extends StatelessWidget {
  const PresensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(title: "Presensi"),
          Gap.h12,
          PresensiOperationsListWidget(
            children: [
              CardPresensiOperation(
                title: "Presensi Kelas",
                onPressedCard: () {
                  context.pushNamed(
                    AppRoute.presensiDetail,
                    extra: const RouteParam(
                      params: {RouteParamKey.presensiType: PresensiType.kelas},
                    ),
                  );
                },
              ),
              Gap.h12,
              CardPresensiOperation(
                title: "Presensi UAS",
                onPressedCard: () {
                  context.pushNamed(
                    AppRoute.presensiDetail,
                    extra: const RouteParam(
                      params: {RouteParamKey.presensiType: PresensiType.uas},
                    ),
                  );
                },
              ),
              Gap.h12,
              CardPresensiOperation(
                title: "Presensi Event",
                onPressedCard: () {
                  context.pushNamed(
                    AppRoute.presensiDetail,
                    extra: const RouteParam(
                      params: {RouteParamKey.presensiType: PresensiType.event},
                    ),
                  );
                },
              ),
            ],
          ),
          Gap.h24,
          // PublishByYouWidget(
          //   data: [
          //     ActivityOverview(
          //       id: "1234-1234",
          //       title: "This is the title of the published data",
          //       type: ActivityType.service,
          //     ),
          //     ActivityOverview(
          //       id: "1234-4411",
          //       title: "Second title of the published data",
          //       type: ActivityType.event,
          //     ),
          //     ActivityOverview(
          //       id: "1234-4556",
          //       title: "published data of the activity overview number 3",
          //       type: ActivityType.announcement,
          //     ),
          //   ],
          //   onPressedViewAll: () {
          //     context.pushNamed(AppRoute.viewAll);
          //   },
          //   onPressedCard: (activityOverview) {},
          // ),
        ],
      ),
    );
  }
}
