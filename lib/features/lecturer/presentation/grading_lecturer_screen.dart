import 'package:flutter/material.dart';
import 'package:inspire/core/widgets/widgets.dart';

class GradingLecturerScreen extends StatelessWidget {
  const GradingLecturerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldWidget(
      appBar: AppBarWidget(title: 'Penilaian'),
      child: Center(
        child: Text('Fitur penilaian segera hadir.'),
      ),
    );
  }
}
