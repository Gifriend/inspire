import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/features/presentation.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  SplashState get state => ref.watch(splashControllerProvider);

  SplashController get controller =>
      ref.read(splashControllerProvider.notifier);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Image.asset(Assets.icons.app.inspireHitam.path)],
          ),
        ),
      ),
    );
  }
}
