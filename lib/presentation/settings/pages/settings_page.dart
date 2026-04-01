import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Notification toggles
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _newProjects = true;
  bool _appUpdates = true;
  bool _messages = true;

  // App prefs
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────────────
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm, vertical: AppSizes.xs),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  Text('Настройки', style: AppTypography.h3),
                ],
              ),
            ),

            // ─── Content ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User preview card
                    _UserPreviewCard(),
                    const SizedBox(height: AppSizes.lg),

                    // Profile settings
                    _SectionTitle(title: 'Настройки профиля'),
                    const SizedBox(height: AppSizes.xs),
                    _SettingsGroup(children: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        iconColor: AppColors.primary,
                        label: 'Редактировать профиль',
                        onTap: () {},
                        showArrow: true,
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.link_rounded,
                        iconColor: AppColors.primary,
                        label: 'Портфолио и ссылки',
                        onTap: () {},
                        showArrow: true,
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        iconColor: AppColors.grey,
                        label: 'Сменить пароль',
                        onTap: () {},
                        showArrow: true,
                      ),
                      _Divider(),
                      _ToggleTile(
                        icon: Icons.dark_mode_outlined,
                        iconColor: AppColors.darkGrey,
                        label: 'Тёмная тема',
                        subtitle: 'Скоро',
                        value: _darkMode,
                        onChanged: (v) => setState(() => _darkMode = v),
                        enabled: false,
                      ),
                    ]),
                    const SizedBox(height: AppSizes.lg),

                    // Notifications
                    _SectionTitle(title: 'Настройки уведомлений'),
                    const SizedBox(height: AppSizes.xs),
                    _SettingsGroup(children: [
                      _ToggleTile(
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.primary,
                        label: 'Push-уведомления',
                        value: _pushEnabled,
                        onChanged: (v) => setState(() => _pushEnabled = v),
                      ),
                      _Divider(),
                      _ToggleTile(
                        icon: Icons.email_outlined,
                        iconColor: AppColors.grey,
                        label: 'Email уведомления',
                        value: _emailEnabled,
                        onChanged: (v) => setState(() => _emailEnabled = v),
                      ),
                      _Divider(),
                      _ToggleTile(
                        icon: Icons.rocket_launch_outlined,
                        iconColor: AppColors.warning,
                        label: 'Новые подходящие проекты',
                        value: _newProjects,
                        onChanged: _pushEnabled
                            ? (v) => setState(() => _newProjects = v)
                            : null,
                        enabled: _pushEnabled,
                      ),
                      _Divider(),
                      _ToggleTile(
                        icon: Icons.inbox_outlined,
                        iconColor: AppColors.success,
                        label: 'Обновления по заявкам',
                        value: _appUpdates,
                        onChanged: _pushEnabled
                            ? (v) => setState(() => _appUpdates = v)
                            : null,
                        enabled: _pushEnabled,
                      ),
                      _Divider(),
                      _ToggleTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: AppColors.primary,
                        label: 'Новые сообщения',
                        value: _messages,
                        onChanged: _pushEnabled
                            ? (v) => setState(() => _messages = v)
                            : null,
                        enabled: _pushEnabled,
                      ),
                    ]),
                    const SizedBox(height: AppSizes.lg),

                    // About
                    _SectionTitle(title: 'О приложении'),
                    const SizedBox(height: AppSizes.xs),
                    _SettingsGroup(children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: AppColors.grey,
                        label: 'Версия приложения',
                        trailing: Text('1.0.0', style: AppTypography.caption),
                        onTap: () {},
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        iconColor: AppColors.grey,
                        label: 'Пользовательское соглашение',
                        onTap: () {},
                        showArrow: true,
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: AppColors.grey,
                        label: 'Политика конфиденциальности',
                        onTap: () {},
                        showArrow: true,
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.star_outline_rounded,
                        iconColor: AppColors.warning,
                        label: 'Оценить приложение',
                        onTap: () {},
                        showArrow: true,
                      ),
                    ]),
                    const SizedBox(height: AppSizes.lg),

                    // Danger zone
                    _SettingsGroup(children: [
                      _SettingsTile(
                        icon: Icons.logout_rounded,
                        iconColor: AppColors.error,
                        label: 'Выйти из аккаунта',
                        labelColor: AppColors.error,
                        onTap: _confirmLogout,
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.delete_forever_outlined,
                        iconColor: AppColors.error,
                        label: 'Удалить аккаунт',
                        labelColor: AppColors.error,
                        onTap: _confirmDeleteAccount,
                      ),
                    ]),

                    const SizedBox(height: AppSizes.xl),
                    Center(
                      child: Text(
                        'ProjectHub · Версия 1.0.0',
                        style: AppTypography.caption,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы сможете войти снова в любое время.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/onboarding');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        title: const Text('Удалить аккаунт?'),
        content: const Text(
            'Все данные будут безвозвратно удалены. Это действие нельзя отменить.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────

class _UserPreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('А',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Алексей Петров',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('@alex_petrov',
                    style: TextStyle(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: const Text('middle',
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(title,
            style: AppTypography.label.copyWith(color: AppColors.grey)),
      );
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
              color: AppColors.dark.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final bool showArrow;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.labelColor,
    this.showArrow = false,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.sm + 2),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(label,
                  style: AppTypography.body
                      .copyWith(color: labelColor ?? AppColors.dark)),
            ),
            if (trailing != null) trailing!,
            if (showArrow)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final bool value;
  final void Function(bool)? onChanged;
  final bool enabled;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.xs + 2),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.body),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.grey)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
      height: 1, indent: AppSizes.md + 34 + AppSizes.sm, endIndent: 0);
}