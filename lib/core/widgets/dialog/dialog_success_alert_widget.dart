import 'package:flutter/material.dart';
import 'package:inspire/core/assets/assets.gen.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/utils.dart';

Future<void> showSuccessAlertDialogWidget(
	BuildContext context, {
	required String title,
	String subtitle = '',
	Future<void> Function()? action,
	String actionButtonTitle = 'OK',
	bool isDissmissible = true,
}) {
	return _showStatusAlertDialogWidget(
		context,
		title: title,
		subtitle: subtitle,
		action: action,
		actionButtonTitle: actionButtonTitle,
		isDissmissible: isDissmissible,
		icon: Assets.images.check.image(
			width: BaseSize.customWidth(100),
			height: BaseSize.customWidth(100),
		),
	);
}

Future<void> showErrorAlertDialogWidget(
	BuildContext context, {
	required String title,
	String subtitle = '',
	Future<void> Function()? action,
	String actionButtonTitle = 'OK',
	bool isDissmissible = true,
}) {
	return _showStatusAlertDialogWidget(
		context,
		title: title,
		subtitle: subtitle,
		action: action,
		actionButtonTitle: actionButtonTitle,
		isDissmissible: isDissmissible,
		icon: Assets.icons.fill.error.svg(
			width: BaseSize.customWidth(72),
			height: BaseSize.customWidth(72),
			colorFilter: BaseColor.red.filterSrcIn,
		),
	);
}

Future<void> _showStatusAlertDialogWidget(
	BuildContext context, {
	required String title,
	required Widget icon,
	String subtitle = '',
	Future<void> Function()? action,
	String actionButtonTitle = 'OK',
	bool isDissmissible = true,
}) {
	return showDialog<void>(
		context: context,
		barrierDismissible: isDissmissible,
		builder: (dialogContext) {
			return Dialog(
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(BaseSize.radiusMd),
				),
				child: Padding(
					padding: EdgeInsets.symmetric(
						horizontal: BaseSize.w24,
						vertical: BaseSize.h24,
					),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							icon,
							Gap.h16,
							Text(
								title,
								textAlign: TextAlign.center,
								style: BaseTypography.titleLarge.fontColor(BaseColor.neutral.shade80),
							),
							if (subtitle.isNotEmpty) ...[
								Gap.h8,
								Text(
									subtitle,
									textAlign: TextAlign.center,
									style: BaseTypography.titleMedium.fontColor(
										BaseColor.neutral.shade60,
									),
								),
							],
							Gap.h24,
							SizedBox(
								width: double.infinity,
								child: ElevatedButton(
									onPressed: () async {
										if (action != null) {
											await action();
										}

										if (dialogContext.mounted) {
											Navigator.of(dialogContext).pop();
										}
									},
									style: ElevatedButton.styleFrom(
										backgroundColor: BaseColor.primaryInspire,
										foregroundColor: BaseColor.white,
									),
									child: Text(actionButtonTitle),
								),
							),
						],
					),
				),
			);
		},
	);
}
