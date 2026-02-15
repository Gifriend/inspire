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
          color: BaseColor.white,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          border: Border.all(color: BaseColor.grey.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: BaseColor.grey,
              blurRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: BaseTypography.titleMedium.bold.toBlack),
                ],
              ),
            ),
            Gap.w12,
            SizedBox(
              width: BaseSize.w24,
              child: Center(
                child: Text("+", style: BaseTypography.headlineSmall.toBlack),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
