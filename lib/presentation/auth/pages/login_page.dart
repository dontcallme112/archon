import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/google_sign_in_button.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/feed');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
              margin: const EdgeInsets.all(AppSizes.md),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.xl),

                  // ─── Logo ──────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusLg),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: AppColors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text('ProjectHub', style: AppTypography.h1),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          'Найди команду для своего проекта',
                          style: AppTypography.body
                              .copyWith(color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.xxl),

                  Text('Войти в аккаунт', style: AppTypography.h2),
                  const SizedBox(height: AppSizes.lg),

                  // ─── Google button ─────────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => GoogleSignInButton(
                      isLoading: state is AuthLoading,
                      onTap: () => context
                          .read<AuthBloc>()
                          .add(AuthGoogleSignInRequested()),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // ─── Divider ───────────────────────────────────
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.sm),
                        child: Text('или', style: AppTypography.caption),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),

                  // ─── Email ─────────────────────────────────────
                  AppTextField(
                    hint: 'example@mail.com',
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: AppColors.grey, size: 20),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Введите email';
                      if (!v.contains('@')) return 'Неверный формат email';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),

                  // ─── Password ──────────────────────────────────
                  AppTextField(
                    hint: '••••••••',
                    label: 'Пароль',
                    controller: _passwordController,
                    maxLines: 1,
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: AppColors.grey, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Введите пароль';
                      if (v.length < 6) return 'Минимум 6 символов';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // ─── Login button ──────────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => PrimaryButton(
                      label: 'Войти',
                      icon: Icons.login_rounded,
                      isLoading: state is AuthLoading,
                      onTap: _submit,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // ─── Register link ─────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => context.push('/register'),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Нет аккаунта? ',
                              style: AppTypography.body
                                  .copyWith(color: AppColors.grey),
                            ),
                            TextSpan(
                              text: 'Зарегистрироваться',
                              style: AppTypography.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }
}
