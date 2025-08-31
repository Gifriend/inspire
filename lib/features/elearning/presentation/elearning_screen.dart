import 'package:flutter/material.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';

import '../../../core/constants/constants.dart';

class ElearningScreen extends StatelessWidget {
  const ElearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> elearningView = [
      {'id': '1'},
      {'id': '2'},
      {'id': '3'},
      {'id': '4'},
      {'id': '5'},
      {'id': '6'},
      {'id': '7'},
      {'id': '8'},
    ];
    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenTitleWidget.titleOnly(title: 'E-Learning'),
          Gap.h20,
          ButtonWidget.primary(
            text: 'Cari Course',
            color: BaseColor.blue.shade900,
            onTap: () {},
          ),
          Gap.h12,
          Text('Daftar Course Anda', style: BaseTypography.titleLarge.toBold),
          Gap.h24,
          SizedBox(
            height: 280.0,
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: elearningView.length,
              itemBuilder: (context, index) {
                final elearning = elearningView[index];
                return _buildPengumumanBookCard(elearning);
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildPengumumanBookCard(Map<String, dynamic> elearning) {
  return Container(
    height: BaseSize.customHeight(280.0),
    child: GestureDetector(
      key: ValueKey(elearning['id']),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: BaseSize.w8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Image
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('Assets.icons.app.logoElearn.path'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Course Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRAKTIKKUM ALGORITMA DAN PREMROGRAMAN 2022',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap.h4,
                      Expanded(
                        child: Text(
                          'INI ADALAH MATAKULIAH WAJIB YANG HARUS DIPELAJARI OLEH SEIAP MAHASISWA INFORMATIKA UNTUK DASAR PEMBELAJARAN',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
