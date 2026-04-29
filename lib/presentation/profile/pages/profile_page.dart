import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/domain/repositories/firestore_user_repository.dart';
import 'package:student_app/presentation/common/widgets/project_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_app/presentation/profile/bloc/profile_bloc.dart';
import 'package:student_app/presentation/profile/bloc/profile_event.dart';
import 'package:student_app/presentation/profile/bloc/profile_state.dart';

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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Не авторизован'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('applicantId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.send_rounded,
                  size: 64,
                  color: AppColors.lightGrey,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  'У вас пока нет заявок',
                  style: AppTypography.h3.copyWith(color: AppColors.grey),
                ),
              ],
            ),
          );
        }

        final docs = snap.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: AppSizes.md),
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dark.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['projectTitle'] ?? 'Проект',
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Статус: ${data['status']}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    data['motivation'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body,
                  ),
                ],
              ),
            );
          },
        );
      },
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