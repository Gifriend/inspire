import 'package:flutter/material.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/utils.dart';

class CardPresensiOperation extends StatelessWidget {
  const CardPresensiOperation({
    super.key,
    required this.title,
    this.description,
    required this.onPressedCard,
  });

  final String title;
  final String? description;
  final VoidCallback onPressedCard;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressedCard,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: BaseSize.w12,
          horizontal: BaseSize.w12,
        ),
        decoration: BoxDecoration(
          color: BaseColor.primaryInspire,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: BaseTypography.titleMedium.bold.toCardBackground1,
                  ),
                ],
              ),
            ),
            Gap.w12,
            SizedBox(
              width: BaseSize.w24,
              child: Center(
                child: Text(
                  "+",
                  style: BaseTypography.headlineSmall.toCardBackground1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
