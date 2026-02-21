import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/login/presentation/login_controller.dart';
import 'package:inspire/features/login/presentation/login_state.dart';
import 'package:inspire/features/profile/presentation/profile_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(loginControllerProvider.notifier).login(
            _nimController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final loginState = ref.watch(loginControllerProvider);

    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      next.maybeWhen(
        success: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login berhasil'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Load user profile
          final profileNotifier = ref.read(profileControllerProvider.notifier);
          profileNotifier.clearCache();
          await profileNotifier.loadProfile(forceRefresh: true);
          
          // Debug: Check loaded user
          final user = profileNotifier.cachedUser;
          if (user != null) {
            debugPrint('🔑 Login - User loaded: ${user.name}, Role: ${user.role}');
          }
          
          if (!context.mounted) return;
          
          // Redirect semua user ke home (baik mahasiswa maupun dosen)
          // HomeScreen akan menampilkan konten sesuai role
          context.goNamed(AppRoute.home);
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        },
        orElse: () {},
      );
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
                child: Form(
                  key: _formKey,
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
                        controller: _nimController,
                        label: 'NIM / NIP',
                        hint: 'Masukkan NIM atau NIP',
                        leadIcon: Assets.icons.fill.user,
                        borderColor: BaseColor.black,
                      ),
                      Gap.h16,
                      InputWidget.text(
                        controller: _passwordController,
                        label: 'Kata Sandi',
                        hint: 'Masukkan Kata Sandi',
                        leadIcon: Assets.icons.fill.key,
                        borderColor: BaseColor.black,
                        obscureText: true,
                      ),
                      Gap.h40,
                      loginState.maybeWhen(
                        loading: () => const CircularProgressIndicator(),
                        orElse: () => ButtonWidget.primary(
                          text: 'Login',
                          textColor: BaseColor.white,
                          color: BaseColor.primaryInspire,
                          focusColor: BaseColor.primaryInspire,
                          overlayColor: BaseColor.primaryInspire,
                          onTap: _handleLogin,
                        ),
                      ),
                      Gap.h24,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
