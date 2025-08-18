import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:inspire/core/widgets/widgets.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // disablePadding: true,
      backgroundColor: BaseColor.primaryInspire,
      body: Stack(
        children: [
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   height: size.height * 0.35,
          //   child: Image.asset(Assets.icons.app.logoInspire.path, fit: BoxFit.cover),
          // ),
          Positioned(
            top: size.height * 0.25,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
              decoration: const BoxDecoration(
                color: BaseColor.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.0),
                  topRight: Radius.circular(28.0),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Selamat Datang Kembali',
                      style: BaseTypography.titleLarge,
                    ),
                    Gap.h6,
                    Image.asset(
                      Assets.icons.app.inspireLogoBlack.path,
                      height: 64,
                    ),
                    // Gap.h8,
                    // Text('', style: BaseTypography.titleLarge),
                    Gap.h32,
                    InputWidget.text(
                      label: 'Username',
                      hint: 'Username',
                      leadIcon: Assets.icons.fill.user,
                      borderColor: BaseColor.black,
                    ),
                    Gap.h16,
                    InputWidget.text(
                      label: 'Kata Sandi',
                      hint: 'Kata Sandi',
                      leadIcon: Assets.icons.fill.key,
                      endIcon: Assets.icons.fill.eyeOn,
                      borderColor: BaseColor.black,
                    ),
                    Gap.h40,
                    ButtonWidget.primary(
                      text: 'Login',
                      textColor: BaseColor.white,
                      color: BaseColor.primaryInspire,
                      focusColor: BaseColor.primaryInspire,
                      overlayColor: BaseColor.primaryInspire,
                      onTap: () => context.goNamed(AppRoute.home),
                    ),
                    Gap.h24,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
