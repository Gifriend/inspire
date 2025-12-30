// lib/features/presentation/splash_controller.dart (assuming path based on import)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:inspire/features/presentation.dart';

import '../../../core/data_sources/data_sources.dart';

part 'splash_controller.g.dart';

@riverpod
class SplashController extends _$SplashController {
  @override
  SplashState build() {
    return const SplashState.initial();
  }

  Future<void> init(BuildContext context) async {
    state = const SplashState.loading();
    try {
      // Short delay for splash effect
      await Future.delayed(const Duration(seconds: 2));

      final hiveService = ref.read(hiveServiceProvider);
      final auth = hiveService.getAuth();

      if (auth != null && auth.accessToken.isNotEmpty && auth.refreshToken.isNotEmpty) {
        state = const SplashState.authenticated();
        context.goNamed(AppRoute.home);
      } else {
        state = const SplashState.unauthenticated();
        context.goNamed(AppRoute.login);
      }
    } catch (e) {
      state = SplashState.error(e.toString());
      // Fallback to login on error
      context.goNamed(AppRoute.login);
    }
  }
}