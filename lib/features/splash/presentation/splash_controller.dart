import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:inspire/features/presentation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_controller.g.dart';

@riverpod
class SplashController extends _$SplashController {
  @override
  SplashState build() {
    return SplashState();
  }

  void init(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 5));
    context.goNamed(AppRoute.dashboard);
  }
}
