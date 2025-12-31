// lib/features/presentation/splash_controller.dart (assuming path based on import)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:inspire/features/presentation.dart';
import 'package:inspire/features/login/domain/services/login_service.dart';

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

      final hiveService = ref.watch(hiveServiceProvider);
      await hiveService.ensureInitialized();
      final loginService = ref.watch(loginServiceProvider);
      final auth = await hiveService.getAuth();

      final hasAccessToken = auth?.accessToken.isNotEmpty ?? false;
      final hasRefreshToken = auth?.refreshToken.isNotEmpty ?? false;

      if (!hasAccessToken && !hasRefreshToken) {
        state = const SplashState.unauthenticated();
        if (context.mounted) {
          context.goNamed(AppRoute.login);
        }
        return;
      }

      if (hasRefreshToken) {
        try {
          await loginService.refreshToken();
          state = const SplashState.authenticated();
          if (context.mounted) {
            context.goNamed(AppRoute.dashboard);
          }
          return;
        } catch (e) {
          state = SplashState.error(e.toString());
          if (context.mounted) {
            context.goNamed(AppRoute.login);
          }
          return;
        }
      }

      state = const SplashState.authenticated();
      if (context.mounted) {
        context.goNamed(AppRoute.dashboard);
      }
    } catch (e) {
      state = SplashState.error(e.toString());
      // Fallback to login on error
      if (context.mounted) {
        context.goNamed(AppRoute.login);
      }
    }
  }
}