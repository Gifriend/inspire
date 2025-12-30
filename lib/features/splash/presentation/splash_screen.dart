import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/features/presentation.dart';

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
      child: Scaffold(
        backgroundColor: BaseColor.primaryInspire,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(Assets.icons.app.logoInspire.path),
              const SizedBox(height: 20),
              splashState.maybeWhen(
                loading: () => const CircularProgressIndicator(color: Colors.white),
                error: (message) => Text(
                  'Error: $message',
                  style: const TextStyle(color: Colors.red),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}