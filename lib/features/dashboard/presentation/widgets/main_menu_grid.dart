import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/routing/routing.dart';
import '../../../presentation.dart';

class MainMenuGrid extends StatelessWidget {
  const MainMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w20, vertical: BaseSize.h20),
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: GridView.count(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
        children: [
          _buildMenuItem(
            icon: Assets.icons.fill.calendar,
            label: 'Kalender',
            onTap: () => context.pushNamed(AppRoute.schedule),
          ),
          _buildMenuItem(
            icon: Assets.images.krs,
            label: 'KRS',
            onTap: () {
              final now = DateTime.now();
              final semesterType = now.month >= 8 ? 'GANJIL' : 'GENAP';
              context.pushNamed(
                AppRoute.krs,
                pathParameters: {'semester': '$semesterType-${now.year}'},
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.book,
            label: 'E-Learning',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ElearningScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: BaseColor.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 0,
                    blurRadius: 3,
                    offset: Offset(0.0, 2),
                  ),
                ],
              ),
              child: Center(child: _buildIcon(icon)),
            ),
            Gap.h8,
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(dynamic icon) {
    if (icon is IconData) {
      return Icon(icon, size: 24.0, color: Colors.grey[700]);
    } else if (icon is SvgGenImage) {
      return icon.svg(width: 24.0, height: 24.0);
    } else if (icon is AssetGenImage) {
      return icon.image(width: 24.0, height: 24.0, color: Colors.grey[700]);
    }
    return const SizedBox.shrink();
  }
}