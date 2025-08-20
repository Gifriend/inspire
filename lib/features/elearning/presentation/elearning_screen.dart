import 'package:flutter/material.dart';
import 'package:inspire/core/widgets/widgets.dart';

class ElearningScreen extends StatelessWidget {
  const ElearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Column(
        children: [ScreenTitleWidget.titleOnly(title: 'E-Learning')],
      ),
    );
  }
}
