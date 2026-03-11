import 'package:flutter/material.dart';

class PresensiOperationsListWidget extends StatelessWidget {
  const PresensiOperationsListWidget({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(children: children);
  }
}
