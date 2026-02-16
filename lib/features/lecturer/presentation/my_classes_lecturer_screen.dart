import 'package:flutter/material.dart';
import 'package:inspire/core/widgets/widgets.dart';

class MyClassesLecturerScreen extends StatelessWidget {
  const MyClassesLecturerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldWidget(
      appBar: AppBarWidget(title: 'Kelas Saya'),
      child: Center(
        child: Text('Fitur kelas saya segera hadir.'),
      ),
    );
  }
}
