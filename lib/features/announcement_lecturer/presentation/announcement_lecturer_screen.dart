import 'package:flutter/material.dart';
import 'package:inspire/core/widgets/widgets.dart';

class AnnouncementLecturerScreen extends StatelessWidget {
	const AnnouncementLecturerScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return const ScaffoldWidget(
			appBar: AppBarWidget(title: 'Pengumuman Dosen'),
			child: Center(
				child: Text('Fitur pengumuman dosen segera hadir.'),
			),
		);
	}
}