import 'package:flutter/material.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';

import '../../../core/constants/constants.dart';

class ElearningScreen extends StatelessWidget {
  const ElearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> elearningView = [
      {
        'id': '1',
        'title': 'PRAKTIKUM ALGORITMA DAN PEMROGRAMAN 2022',
        'description':
            'INI ADALAH MATAKULIAH WAJIB YANG HARUS DIPELAJARI OLEH SETIAP MAHASISWA INFORMATIKA UNTUK DASAR PEMBELAJARAN',
        'image': 'assets/icons/app/inspire-logo-black.png',
      },
      {
        'id': '2',
        'title': 'STRUKTUR DATA DAN ALGORITMA',
        'description':
            'MEMPELAJARI KONSEP DASAR STRUKTUR DATA DAN IMPLEMENTASINYA DALAM PEMROGRAMAN',
        'image': 'assets/icons/app/inspire-logo-black.png',
      },
      {
        'id': '3',
        'title': 'DATABASE MANAGEMENT SYSTEM',
        'description': 'MEMPELAJARI KONSEP DASAR DATABASE DAN QUERY MANAGEMENT',
        'image': 'assets/icons/app/inspire-logo-black.png',
      },
      {
        'id': '4',
        'title': 'PEMROGRAMAN WEB',
        'description': 'MEMPELAJARI PENGEMBANGAN APLIKASI WEB MODERN',
        'image': 'assets/icons/app/inspire-logo-black.png',
      },
      {
        'id': '5',
        'title': 'MOBILE APPLICATION DEVELOPMENT',
        'description':
            'MEMPELAJARI PENGEMBANGAN APLIKASI MOBILE DENGAN FLUTTER',
        'image': 'assets/icons/app/inspire-logo-black.png',
      },
      {
        'id': '6',
        'title': 'MACHINE LEARNING BASICS',
        'description': 'PENGENALAN KONSEP DASAR MACHINE LEARNING DAN AI',
        'image': 'assets/icons/app/inspire-logo-black.png',
      },
      {
        'id': '7',
        'title': 'CYBER SECURITY',
        'description': 'MEMPELAJARI KONSEP KEAMANAN SIBER DAN PROTEKSI DATA',
        'image': 'assets/icons/app/inspire-logo-black.png',
      },
      {
        'id': '8',
        'title': 'SOFTWARE ENGINEERING',
        'description': 'MEMPELAJARI METODOLOGI PENGEMBANGAN PERANGKAT LUNAK',
        'image': 'assets/icons/app/inspire-logo-black.png',
      },
    ];

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap.h16,
          ScreenTitleWidget.titleOnly(title: 'E-Learning'),
          Gap.h20,
          ButtonWidget.primary(
            text: 'Cari Course',
            color: BaseColor.primaryInspire,
            onTap: () {},
          ),
          Gap.h12,
          Text('Daftar Course Anda', style: BaseTypography.titleLarge.toBold),
          Gap.h24,
          Expanded(
            child: GridView.builder(
              physics: const ClampingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 1.8,
                crossAxisSpacing: BaseSize.w8,
                mainAxisSpacing: BaseSize.h8,
              ),
              itemCount: elearningView.length,
              itemBuilder: (context, index) {
                final elearning = elearningView[index];
                return _buildElearningCard(context, elearning);
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildElearningCard(
  BuildContext context,
  Map<String, dynamic> elearning,
) {
  return GestureDetector(
    key: ValueKey(elearning['id']),
    onTap: () {
      print('Tapped course: ${elearning['title']}');
    },
    child: Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      color: BaseColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                child: _buildCourseImage(elearning['image']),
              ),
            ),

            // Course Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(BaseSize.w12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      elearning['title'] ?? 'Course Title',
                      style: BaseTypography.bodyMedium.toBold,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.h4,
                    Expanded(
                      child: Text(
                        elearning['description'] ?? 'Course description',
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.grey.shade600,
                        ),
                        maxLines: 1,
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
  );
}

// Widget untuk menampilkan image dengan error handling
Widget _buildCourseImage(String? imagePath) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(color: BaseColor.grey[100]),
    child: imagePath != null
        ? Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback jika image tidak ditemukan
              return _buildImagePlaceholder();
            },
          )
        : _buildImagePlaceholder(),
  );
}

// Placeholder jika image tidak ada atau error
Widget _buildImagePlaceholder() {
  return Container(
    width: double.infinity,
    color: BaseColor.grey[200],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.school, size: 40, color: BaseColor.grey[400]),
        Gap.h8,
        Text(
          'Course Image',
          style: TextStyle(fontSize: 12, color: BaseColor.grey[500]),
        ),
      ],
    ),
  );
}

// Alternative: Menggunakan generated assets (jika tersedia)
Widget _buildCourseImageWithGenerated(String? imagePath) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(color: BaseColor.grey[100]),
    child: imagePath != null
        ?
          // Jika menggunakan generated assets:
          // Assets.icons.app.logoElearn.image(
          //   fit: BoxFit.cover,
          //   errorBuilder: (context, error, stackTrace) {
          //     return _buildImagePlaceholder();
          //   },
          // )
          // Atau menggunakan Image.asset biasa:
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          )
        : _buildImagePlaceholder(),
  );
}
