import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/domain/repositories/firestore_user_repository.dart';
import 'package:student_app/presentation/common/widgets/project_card.dart';
import 'package:student_app/presentation/profile/pages/profile_bloc.dart';
import 'package:student_app/presentation/profile/pages/profile_event.dart';
import 'package:student_app/presentation/profile/pages/profile_state.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      body: BlocProvider<ProfileBloc>(
        create: (context) =>
            ProfileBloc(userRepository: FirestoreUserRepository())
              ..add(LoadProfileData()),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileError) {
              return Center(child: Text(state.message));
            }
            if (state is ProfileLoaded) {
              return _buildContent(context, state.user, state.projects);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    UserEntity user,
    List<ProjectEntity> projects,
  ) {
    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: _buildHeader(context, user, projects.length),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.grey,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Мои проекты'),
                  Tab(text: 'Мои заявки'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _MyProjectsTab(projects: projects),
            const _MyApplicationsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    UserEntity user,
    int projectsCount,
  ) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Профиль', style: AppTypography.h2),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          Row(
            children: [
              AppAvatar(name: user.name, imageUrl: user.avatarUrl, size: 72),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: AppTypography.h3),
                    if (user.bio != null && user.bio!.isNotEmpty)
                      Text(user.bio!, style: AppTypography.caption),
                    if (user.portfolioUrl != null && user.portfolioUrl!.isNotEmpty)
                      Text(
                        user.portfolioUrl!,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.primary),
                      ),
                    if (user.telegram != null && user.telegram!.isNotEmpty)
                      Text(user.telegram!, style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          Row(
            children: [
              _StatBadge(value: '$projectsCount', label: 'Проектов'),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          if (user.skills.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: user.skills.map((s) => SkillChip(label: s)).toList(),
            ),
          const SizedBox(height: AppSizes.md),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Редактировать профиль'),
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // ✅ Кнопка создать проект
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/project/create'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Создать проект'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PROJECTS TAB ─────────────────────────────────────────────────────────

class _MyProjectsTab extends StatelessWidget {
  final List<ProjectEntity> projects;
  const _MyProjectsTab({required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_rounded,
                size: 64, color: AppColors.lightGrey),
            const SizedBox(height: AppSizes.md),
            Text('Нет проектов',
                style: AppTypography.h3.copyWith(color: AppColors.grey)),
            const SizedBox(height: AppSizes.sm),
            Text('Создай первый проект',
                style: AppTypography.body.copyWith(color: AppColors.grey)),
            const SizedBox(height: AppSizes.md),
            ElevatedButton.icon(
              onPressed: () => context.push('/project/create'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Создать проект'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: projects.length,
      // ✅ Используем ProjectCard как в ленте
      itemBuilder: (context, i) => ProjectCard(project: projects[i]),
    );
  }
}

// ─── APPLICATIONS TAB ─────────────────────────────────────────────────────

class _MyApplicationsTab extends StatelessWidget {
  const _MyApplicationsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.send_rounded, size: 64, color: AppColors.lightGrey),
          const SizedBox(height: AppSizes.md),
          Text('Нет заявок',
              style: AppTypography.h3.copyWith(color: AppColors.grey)),
        ],
      ),
    );
  }
}

// ─── WIDGETS ──────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.h2),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(context, shrinkOffset, overlapsContent) =>
      Container(color: AppColors.white, child: tabBar);

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_) => false;
}