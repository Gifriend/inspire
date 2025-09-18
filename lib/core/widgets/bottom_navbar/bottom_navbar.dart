import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../assets/assets.dart';
import '../../constants/constants.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onPressedItem,
  });

  final int currentIndex;
  final Function(int) onPressedItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 80,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Background bar
            Positioned.fill(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(
                      icon: Assets.icons.fill.home,
                      label: 'dashboard',
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Icons.back_hand,
                      label: 'Presnsi',
                      index: 1,
                    ),
                    _buildNavItem(
                      icon: Assets.icons.fill.other,
                      label: 'Lainnya',
                      index: 3,
                    ),
                    _buildNavItem(
                      icon: Assets.icons.fill.user,
                      label: 'Akun',
                      index: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required dynamic icon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onPressedItem(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: BaseSize.h24,
            width: BaseSize.w24,
            child: _buildIcon(icon, isActive),
          ),
          Gap.h4,
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? BaseColor.primaryInspire : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(dynamic icon, bool isActive) {
    try {
      if (icon is SvgGenImage) {
        return icon.svg(
          height: BaseSize.h24,
          width: BaseSize.w24,
          colorFilter: ColorFilter.mode(
            isActive ? BaseColor.primaryInspire : Colors.grey,
            BlendMode.srcIn,
          ),
        );
      } else if (icon is AssetGenImage) {
        return Image.asset(
          icon.path,
          height: BaseSize.h24,
          width: BaseSize.w24,
          color: isActive ? BaseColor.primaryInspire : Colors.grey,
        );
      } else if (icon is IconData) {
        return Icon(
          icon,
          color: isActive ? BaseColor.primaryInspire : Colors.grey,
          size: 24,
        );
      } else {
        return Icon(
          Icons.help_outline,
          color: isActive ? BaseColor.primaryInspire : Colors.grey,
          size: 24,
        );
      }
    } catch (_) {
      return Icon(
        Icons.error_outline,
        color: isActive ? BaseColor.primaryInspire : Colors.grey,
        size: 24,
      );
    }
  }
}
