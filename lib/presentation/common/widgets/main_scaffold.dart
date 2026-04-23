import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/feed')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/notifications')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _selectedIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Лента',
                  isSelected: index == 0,
                  onTap: () => context.go('/feed'),
                ),
                _NavItem(
                  icon: Icons.search_rounded,
                  label: 'Поиск',
                  isSelected: index == 1,
                  onTap: () => context.go('/search'),
                ),
                _AddButton(onTap: () {
                  if (FirebaseAuth.instance.currentUser == null) {
                    context.push('/register');
                    return;
                  }
                  context.push('/project/create');
                }),
                _NavItem(
                  icon: Icons.notifications_rounded,
                  label: 'Уведомления',
                  isSelected: index == 2,
                  onTap: () => context.go('/notifications'),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Профиль',
                  isSelected: index == 3,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? AppColors.primary : AppColors.grey,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 28),
      ),
    );
  }
}