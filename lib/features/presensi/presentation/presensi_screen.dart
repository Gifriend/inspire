import 'package:flutter/material.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presensi/presentation/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';

class PresensiScreen extends StatelessWidget {
  const PresensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      appBar: AppBarWidget(title: "Presensi"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap.h12,
          PresensiOperationsListWidget(
            children: [
              CardPresensiOperation(
                title: "Presensi Kelas",
                onPressedCard: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PresensiDetailScreen(type: PresensiType.kelas),
                    ),
                  );
                },
              ),
              Gap.h12,
              CardPresensiOperation(
                title: "Presensi UAS",
                onPressedCard: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PresensiDetailScreen(type: PresensiType.uas),
                    ),
                  );
                },
              ),
              Gap.h12,
              CardPresensiOperation(
                title: "Presensi Event",
                onPressedCard: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PresensiDetailScreen(type: PresensiType.event),
                    ),
                  );
                },
              ),
            ],
          ),
          Gap.h24,
        ],
      ),
    );
  }
}
