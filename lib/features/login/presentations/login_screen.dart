import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/login/presentations/login_controller.dart';
import 'package:inspire/features/login/presentations/login_state.dart';
import 'package:inspire/features/profile/presentation/profile_controller.dart';
import 'package:inspire/features/schedule/presentation/schedule_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  void _handleLogin() {
    ref.read(loginControllerProvider.notifier).login();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final loginState = ref.watch(loginControllerProvider);

    ref.listen<LoginState>(loginControllerProvider, (previous, next) async {
      final prevStatus = previous?.status;
      final nextStatus = next.status;

      if (prevStatus == nextStatus) {
        return;
      }

      if (nextStatus == LoginSubmitStatus.success) {
        await showSuccessAlertDialogWidget(
          context,
          title: 'Login berhasil',
          actionButtonTitle: 'Lanjut',
        );

        if (!context.mounted) return;

        final profileNotifier = ref.read(profileControllerProvider.notifier);
        profileNotifier.clearCache();
        await profileNotifier.loadProfile(forceRefresh: true);
        ref.invalidate(scheduleControllerProvider);

        final user = profileNotifier.cachedUser;
        if (user != null) {
          debugPrint('🔑 Login - User loaded: ${user.name}, Role: ${user.role}');
        }

        ref.read(loginControllerProvider.notifier).clearFeedback();

        if (!context.mounted) return;
        context.goNamed(AppRoute.home);
        return;
      }

      if (nextStatus == LoginSubmitStatus.error &&
          (next.errorMessage?.isNotEmpty ?? false)) {
        await showErrorAlertDialogWidget(
          context,
          title: 'Login gagal',
          subtitle: next.errorMessage!,
        );
        ref.read(loginControllerProvider.notifier).clearFeedback();
      }
    });

    return ScaffoldWidget(
      resizeToAvoidBottomInset: true,
      disablePadding: true,
      disableSingleChildScrollView: true,
      backgroundColor: BaseColor.primaryInspire,
      child: Stack(
        children: [
          Positioned(
            top: size.height * 0.25,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
              decoration: BoxDecoration(
                color: BaseColor.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(BaseSize.radiusXl),
                  topRight: Radius.circular(BaseSize.radiusXl),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 48.0,
                  bottom: viewInsets + 24,
                ),
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
                    Gap.h32,
                    InputWidget.text(
                      currentInputValue: loginState.identifier,
                      label: 'NIM / NIP',
                      hint: 'Masukkan NIM atau NIP',
                      leadIcon: Assets.icons.fill.user,
                      borderColor: BaseColor.black,
                      onChanged: (value) {
                        ref
                            .read(loginControllerProvider.notifier)
                            .updateIdentifier(value.toString());
                      },
                    ),
                    Gap.h16,
                    InputWidget.text(
                      currentInputValue: loginState.password,
                      label: 'Kata Sandi',
                      hint: 'Masukkan Kata Sandi',
                      leadIcon: Assets.icons.fill.key,
                      borderColor: BaseColor.black,
                      obscureText: true,
                      onChanged: (value) {
                        ref
                            .read(loginControllerProvider.notifier)
                            .updatePassword(value.toString());
                      },
                    ),
                    Gap.h40,
                    loginState.status == LoginSubmitStatus.loading
                        ? const CircularProgressIndicator()
                        : ButtonWidget.primary(
                            text: 'Login',
                            textColor: BaseColor.white,
                            color: BaseColor.primaryInspire,
                            focusColor: BaseColor.primaryInspire,
                            overlayColor: BaseColor.primaryInspire,
                            onTap: _handleLogin,
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
