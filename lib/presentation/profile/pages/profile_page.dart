import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/entities.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock current user
  final _user = const UserEntity(
    id: 'u1',
    name: 'Алексей Петров',
    telegram: '@alex_petrov',
    skills: ['UI/UX', 'Product Design', 'Figma'],
    level: 'middle',
    portfolioUrl: 'behance.net/alex_petrov',
    bio: 'Дизайнер продуктов, ищу интересные проекты для практики',
  );

  final _myProjects = [
    _ProjectItem(id: 'p1', title: 'Разработка E-commerce', subtitle: 'Разработка E-commerce', isActive: false, membersCount: 3),
    _ProjectItem(id: 'p2', title: 'AI Стартап', subtitle: 'Активная роль', isActive: true, membersCount: 2),
  ];

  final _myApplications = [
    _AppItem(title: 'Redesign фитнес-приложения', role: 'UI/UX Дизайнер', status: ApplicationStatus.pending),
    _AppItem(title: 'Маркетинг стартапа', role: 'SMM специалист', status: ApplicationStatus.accepted),
    _AppItem(title: 'E-commerce платформа', role: 'Product Designer', status: ApplicationStatus.rejected),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.grey,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2,
                  labelStyle: AppTypography.label,
                  tabs: const [
                    Tab(text: 'Мои проекты'),
                    Tab(text: 'Мои заявки'),
                    Tab(text: 'Избранное ❤️'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _MyProjectsTab(projects: _myProjects),
              _MyApplicationsTab(applications: _myApplications),
              const _FavoritesTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        children: [
          // Top row: title + settings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Профиль', style: AppTypography.h2),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 22, color: AppColors.dark),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded, size: 22, color: AppColors.dark),
                    onPressed: () => context.push('/settings'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Avatar + info
          Row(
            children: [
              // Avatar with level badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AppAvatar(name: _user.name, imageUrl: _user.avatarUrl, size: 72),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: Text(
                        _user.level,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_user.name, style: AppTypography.h3),
                    const SizedBox(height: 2),
                    if (_user.bio != null)
                      Text(_user.bio!, style: AppTypography.caption, maxLines: 2),
                    const SizedBox(height: 4),
                    if (_user.portfolioUrl != null)
                      Row(
                        children: [
                          const Icon(Icons.link_rounded, size: 13, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            _user.portfolioUrl!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    if (_user.telegram != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.telegram, size: 13, color: AppColors.grey),
                          const SizedBox(width: 3),
                          Text(_user.telegram!, style: AppTypography.caption),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Stats row
          Row(
            children: [
              _StatBadge(value: '${_myProjects.length}', label: 'Проектов'),
              _divider(),
              _StatBadge(value: '${_myApplications.length}', label: 'Заявок'),
              _divider(),
              _StatBadge(
                value: '${_myApplications.where((a) => a.status == ApplicationStatus.accepted).length}',
                label: 'Принято',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Skills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _user.skills.map((s) => SkillChip(label: s)).toList(),
          ),
          const SizedBox(height: AppSizes.md),

          // Edit button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Редактировать профиль'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size.zero,
                textStyle: AppTypography.label,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1, height: 28, color: AppColors.lightGrey,
    margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
  );
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.h2.copyWith(color: AppColors.primary)),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

// ─── Tabs ─────────────────────────────────────────────────────────────────

class _MyProjectsTab extends StatelessWidget {
  final List<_ProjectItem> projects;
  const _MyProjectsTab({required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return _EmptyState(
        icon: Icons.folder_open_rounded,
        label: 'Нет проектов',
        actionLabel: 'Создать проект',
        onAction: () => context.push('/project/create'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: projects.length,
      itemBuilder: (context, i) {
        final p = projects[i];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            boxShadow: [
              BoxShadow(color: AppColors.dark.withOpacity(0.04), blurRadius: 6),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.xs),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: const Icon(Icons.folder_rounded, color: AppColors.primary, size: 22),
            ),
            title: Text(p.title, style: AppTypography.h4),
            subtitle: Row(
              children: [
                const Icon(Icons.people_rounded, size: 12, color: AppColors.grey),
                const SizedBox(width: 3),
                Text('${p.membersCount} участников', style: AppTypography.caption),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (p.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      '● active',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
              ],
            ),
            onTap: () => context.push('/project/${p.id}'),
          ),
        );
      },
    );
  }
}

class _MyApplicationsTab extends StatelessWidget {
  final List<_AppItem> applications;
  const _MyApplicationsTab({required this.applications});

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return _EmptyState(
        icon: Icons.inbox_rounded,
        label: 'Нет активных заявок',
        actionLabel: 'Откликнуться на проекты',
        onAction: () => context.go('/feed'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: applications.length,
      itemBuilder: (context, i) {
        final app = applications[i];
        final statusData = switch (app.status) {
          ApplicationStatus.pending => (
              label: 'На рассмотрении',
              color: AppColors.warning,
              bg: const Color(0xFFFFF3E0)
            ),
          ApplicationStatus.accepted => (
              label: 'Принято ✓',
              color: AppColors.success,
              bg: const Color(0xFFE8F5E9)
            ),
          ApplicationStatus.rejected => (
              label: 'Отклонено',
              color: AppColors.error,
              bg: const Color(0xFFFFEBEE)
            ),
        };

        return Container(
          margin: const EdgeInsets.only(bottom: AppSizes.sm),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            boxShadow: [
              BoxShadow(color: AppColors.dark.withOpacity(0.04), blurRadius: 6),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.title, style: AppTypography.h4, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(app.role, style: AppTypography.caption.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusData.bg,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  statusData.label,
                  style: AppTypography.caption
                      .copyWith(color: statusData.color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      icon: Icons.favorite_border_rounded,
      label: 'Нет избранных проектов',
      actionLabel: 'Посмотреть ленту',
      onAction: () => context.go('/feed'),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.label,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.lightGrey),
          const SizedBox(height: AppSizes.md),
          Text(label, style: AppTypography.h3.copyWith(color: AppColors.grey)),
          const SizedBox(height: AppSizes.md),
          ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

// ─── SliverPersistentHeader for TabBar ────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}

// ─── Internal models ──────────────────────────────────────────────────────

class _ProjectItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isActive;
  final int membersCount;
  const _ProjectItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.membersCount,
  });
}

class _AppItem {
  final String title;
  final String role;
  final ApplicationStatus status;
  const _AppItem({required this.title, required this.role, required this.status});
}