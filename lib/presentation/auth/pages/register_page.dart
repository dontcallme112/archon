import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/google_sign_in_button.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/onboarding');
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  Text('Создать аккаунт', style: AppTypography.h1),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Найди проект или собери свою команду',
                    style: AppTypography.body.copyWith(color: AppColors.grey),
                  ),
                  const SizedBox(height: AppSizes.xl),

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

                  // ─── Name ──────────────────────────────────────
                  AppTextField(
                    hint: 'Алексей Петров',
                    label: 'Имя',
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.person_outline_rounded,
                        color: AppColors.grey, size: 20),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Введите имя';
                      if (v.trim().length < 2) return 'Слишком короткое имя';
                      return null;
                    },
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
                  const SizedBox(height: AppSizes.md),

                  // ─── Confirm ───────────────────────────────────
                  AppTextField(
                    hint: '••••••••',
                    label: 'Подтвердить пароль',
                    controller: _confirmController,
                    maxLines: 1,
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: AppColors.grey, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Повторите пароль';
                      if (v != _passwordController.text)
                        return 'Пароли не совпадают';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // ─── Register button ───────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => PrimaryButton(
                      label: 'Зарегистрироваться',
                      icon: Icons.rocket_launch_rounded,
                      isLoading: state is AuthLoading,
                      onTap: _submit,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // ─── Login link ────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Уже есть аккаунт? ',
                              style: AppTypography.body
                                  .copyWith(color: AppColors.grey),
                            ),
                            TextSpan(
                              text: 'Войти',
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
          AuthRegisterRequested(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
          ),
        );
  }
}
