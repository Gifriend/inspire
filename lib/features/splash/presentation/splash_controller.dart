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
    final minDisplay = const Duration(milliseconds: 800);
    final start = DateTime.now();

    try {
      final hiveService = ref.watch(hiveServiceProvider);
      await hiveService.ensureInitialized();
      final loginService = ref.watch(loginServiceProvider);
      final auth = await hiveService.getAuth();

      final hasAccessToken = auth?.accessToken.isNotEmpty ?? false;
      final hasRefreshToken = auth?.refreshToken.isNotEmpty ?? false;

      if (!hasAccessToken && !hasRefreshToken) {
        state = const SplashState.unauthenticated();
        final elapsed = DateTime.now().difference(start);
        if (elapsed < minDisplay) await Future.delayed(minDisplay - elapsed);
        if (context.mounted) context.goNamed(AppRoute.login);
        return;
      }

      if (hasRefreshToken) {
        try {
          // Try refreshing but don't block too long; if network is poor, we'll fallback to offline.
          await loginService.refreshToken().timeout(const Duration(seconds: 3));
          state = const SplashState.authenticated();
          final elapsed = DateTime.now().difference(start);
          if (elapsed < minDisplay) await Future.delayed(minDisplay - elapsed);
          if (context.mounted) context.goNamed(AppRoute.home);
          return;
        } catch (e) {
          // Refresh failed (network/token). If we have local auth stored, allow offline mode.
          if (auth != null) {
            state = const SplashState.offline();
            final elapsed = DateTime.now().difference(start);
            if (elapsed < minDisplay) await Future.delayed(minDisplay - elapsed);
            if (context.mounted) context.goNamed(AppRoute.home);
            return;
          }

          // No usable local auth -> go to login
          state = SplashState.error(e.toString());
          final elapsed = DateTime.now().difference(start);
          if (elapsed < minDisplay) await Future.delayed(minDisplay - elapsed);
          if (context.mounted) context.goNamed(AppRoute.login);
          return;
        }
      }

      // Has only access token (no refresh). Allow offline access using cached data.
      state = const SplashState.offline();
      final elapsed = DateTime.now().difference(start);
      if (elapsed < minDisplay) await Future.delayed(minDisplay - elapsed);
      if (context.mounted) context.goNamed(AppRoute.home);
    } catch (e) {
      // Unexpected error: fallback to login unless there's cached auth
      final hiveService = ref.watch(hiveServiceProvider);
      final auth = await hiveService.getAuth();
      if (auth != null) {
        state = const SplashState.offline();
        final elapsed = DateTime.now().difference(start);
        if (elapsed < minDisplay) await Future.delayed(minDisplay - elapsed);
        if (context.mounted) context.goNamed(AppRoute.home);
        return;
      }

      state = SplashState.error(e.toString());
      final elapsed = DateTime.now().difference(start);
      if (elapsed < minDisplay) await Future.delayed(minDisplay - elapsed);
      if (context.mounted) context.goNamed(AppRoute.login);
    }
  }
}