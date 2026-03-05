import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/features/presentation.dart';

import '../../../core/widgets/widgets.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashControllerProvider.notifier).init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final splashState = ref.watch(splashControllerProvider);

    return SafeArea(
      child: ScaffoldWidget(
        disableSingleChildScrollView: true,
        disablePadding: true,
        backgroundColor: BaseColor.primaryInspire,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              splashState.maybeWhen(
                loading: () => Image.asset(Assets.icons.app.logoInspire.path),
                // error: Image.asset(Assets.icons.app.logoInspire.path),
                orElse: () => Image.asset(Assets.icons.app.logoInspire.path),
              ),
            ],
          ),
        ),
      ),
    );
  }
}