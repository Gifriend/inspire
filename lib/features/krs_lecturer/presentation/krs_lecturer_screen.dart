import 'package:flutter/material.dart';
import 'package:inspire/core/widgets/widgets.dart';

class KrsLecturerScreen extends StatelessWidget {
	const KrsLecturerScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return const ScaffoldWidget(
			appBar: AppBarWidget(title: 'Persetujuan KRS'),
			child: Center(
				child: Text('Fitur persetujuan KRS segera hadir.'),
			),
		);
	}
}