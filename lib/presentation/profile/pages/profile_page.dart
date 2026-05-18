import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/domain/repositories/firestore_user_repository.dart';
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
                tabs: [
                  Tab(text: 'Мои проекты (${projects.length})'),
                  const Tab(text: 'Мои заявки'),
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
                    if (user.portfolioUrl != null &&
                        user.portfolioUrl!.isNotEmpty)
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

// ─── MY PROJECTS TAB ─────────────────────────────────────────────────────

class _MyProjectsTab extends StatelessWidget {
  final List<ProjectEntity> projects;
  const _MyProjectsTab({required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
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
                  style: AppTypography.body.copyWith(color: AppColors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.lg),
              SizedBox(
                width: 230,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/project/create'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Создать проект'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        final Map<String, int> pendingCounts = {};

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final projectId = data['projectId'];
            if (projectId is String) {
              pendingCounts[projectId] = (pendingCounts[projectId] ?? 0) + 1;
            }
          }
        }

        final originalIndex = {
          for (int i = 0; i < projects.length; i++) projects[i].id: i,
        };

        final sortedProjects = [...projects];
        sortedProjects.sort((a, b) {
          final aCount = pendingCounts[a.id] ?? 0;
          final bCount = pendingCounts[b.id] ?? 0;
          if (aCount != bCount) return bCount.compareTo(aCount);
          return originalIndex[a.id]!.compareTo(originalIndex[b.id]!);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: sortedProjects.length,
          itemBuilder: (context, i) {
            final project = sortedProjects[i];
            final pendingCount = pendingCounts[project.id] ?? 0;

            // GestureDetector без AbsorbPointer — нажатие работает
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _OwnerProjectPage(project: project),
                ),
              ),
              child: _MyProjectCard(
                project: project,
                pendingCount: pendingCount,
              ),
            );
          },
        );
      },
    );
  }
}

// ─── MY PROJECT CARD ─────────────────────────────────────────────────────

class _MyProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final int pendingCount;

  const _MyProjectCard({
    required this.project,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: AppSizes.md),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.3), width: 1.5),
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
              // Теги
              Row(
                children: [
                  _Tag(
                    label: project.category,
                    color: AppColors.primarySurface,
                    textColor: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  _Tag(
                    label: project.level.toUpperCase(),
                    color: const Color(0xFFF0F4FF),
                    textColor: const Color(0xFF3D5AFE),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),

              Text(
                project.title,
                style: AppTypography.h3,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              if (project.shortDescription.isNotEmpty)
                Text(
                  project.shortDescription,
                  style: AppTypography.body
                      .copyWith(color: AppColors.darkGrey, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: AppSizes.sm),

              if (project.requiredSkills.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: project.requiredSkills
                      .take(4)
                      .map((s) => SkillChip(label: s))
                      .toList(),
                ),
              const SizedBox(height: AppSizes.sm),

              Row(
                children: [
                  DeadlineBadge(deadline: project.deadline),
                  const Spacer(),
                  Text(
                    '${project.filledSlots}/${project.totalSlots} мест',
                    style:
                        AppTypography.caption.copyWith(color: AppColors.grey),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),

              // Кнопки
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/project/${project.id}/edit'),
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Редактировать'),
                      style: OutlinedButton.styleFrom(
                        minimumSize:
                            const Size(0, AppSizes.buttonHeight - 8),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context
                          .push('/project/${project.id}/applications'),
                      icon: const Icon(Icons.people_rounded, size: 16),
                      label: Text(pendingCount > 0
                          ? 'Заявки ($pendingCount)'
                          : 'Заявки'),
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            const Size(0, AppSizes.buttonHeight - 8),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Бейдж с количеством заявок
        if (pendingCount > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              constraints:
                  const BoxConstraints(minWidth: 22, minHeight: 22),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  pendingCount > 99 ? '99+' : '$pendingCount',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Tag({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── OWNER PROJECT PAGE ──────────────────────────────────────────────────

class _OwnerProjectPage extends StatelessWidget {
  final ProjectEntity project;
  const _OwnerProjectPage({required this.project});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(project.title),
          actions: [
            IconButton(
              tooltip: 'Редактировать',
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => context.push('/project/${project.id}/edit'),
            ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'Проект'), Tab(text: 'Заявки')],
          ),
        ),
        body: TabBarView(
          children: [
            _OwnerProjectInfoTab(project: project),
            _OwnerProjectApplicationsTab(projectId: project.id),
          ],
        ),
      ),
    );
  }
}

class _OwnerProjectInfoTab extends StatelessWidget {
  final ProjectEntity project;
  const _OwnerProjectInfoTab({required this.project});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.sm),
          Text(project.title, style: AppTypography.h1),
          const SizedBox(height: AppSizes.md),
          if (project.fullDescription.isNotEmpty)
            Text(project.fullDescription,
                style:
                    AppTypography.body.copyWith(color: AppColors.darkGrey))
          else
            Text('Описание не указано',
                style: AppTypography.body.copyWith(color: AppColors.grey)),
          const SizedBox(height: AppSizes.lg),
          if (project.requiredSkills.isNotEmpty) ...[
            Text('Нужные навыки', style: AppTypography.h3),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.requiredSkills
                  .map((s) => SkillChip(label: s))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _OwnerProjectApplicationsTab extends StatelessWidget {
  final String projectId;
  const _OwnerProjectApplicationsTab({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('projectId', isEqualTo: projectId)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text('Ошибка: ${snap.error}',
                style: AppTypography.body.copyWith(color: AppColors.error)),
          );
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(
            child: Text('Заявок пока нет',
                style: AppTypography.h3.copyWith(color: AppColors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, i) {
            final doc = snap.data!.docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            final isPending = status == 'pending';

            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      _ApplicationDetailsPage(applicationRef: doc.reference),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSizes.md),
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.dark.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppAvatar(
                            name: data['applicantName'] ?? 'User',
                            imageUrl: data['applicantAvatarUrl'],
                            size: 42),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['applicantName'] ?? 'Пользователь',
                                  style: AppTypography.h3),
                              Text(data['role'] ?? '',
                                  style: AppTypography.caption
                                      .copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                        _StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(data['motivation'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body),
                    if (isPending) ...[
                      const SizedBox(height: AppSizes.md),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _updateApplicationStatus(
                                  context: context,
                                  applicationRef: doc.reference,
                                  accept: false),
                              icon: const Icon(Icons.close_rounded, size: 18),
                              label: const Text('Отклонить'),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateApplicationStatus(
                                  context: context,
                                  applicationRef: doc.reference,
                                  accept: true),
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Принять'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── APPLICATION DETAILS PAGE ────────────────────────────────────────────

class _ApplicationDetailsPage extends StatelessWidget {
  final DocumentReference applicationRef;
  const _ApplicationDetailsPage({required this.applicationRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Заявка')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: applicationRef.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'pending';
          final isPending = status == 'pending';
          final skills = List<String>.from(data['skills'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppAvatar(
                              name: data['applicantName'] ?? 'User',
                              imageUrl: data['applicantAvatarUrl'],
                              size: 56),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['applicantName'] ?? 'Пользователь',
                                    style: AppTypography.h2),
                                const SizedBox(height: 4),
                                _StatusBadge(status: status),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),
                      _InfoRow(label: 'Роль', value: data['role'] ?? '-'),
                      _InfoRow(
                          label: 'Telegram', value: data['telegram'] ?? '-'),
                      _InfoRow(
                          label: 'Портфолио',
                          value: data['portfolioUrl'] ?? '-'),
                      const SizedBox(height: AppSizes.md),
                      Text('Навыки', style: AppTypography.label),
                      const SizedBox(height: AppSizes.xs),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            skills.map((s) => SkillChip(label: s)).toList(),
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text('Мотивация', style: AppTypography.label),
                      const SizedBox(height: AppSizes.xs),
                      Text(data['motivation'] ?? '',
                          style: AppTypography.body),
                    ],
                  ),
                ),
                if (isPending) ...[
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _updateApplicationStatus(
                              context: context,
                              applicationRef: applicationRef,
                              accept: false),
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Отклонить'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateApplicationStatus(
                              context: context,
                              applicationRef: applicationRef,
                              accept: true),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Принять'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── MY APPLICATIONS TAB ─────────────────────────────────────────────────

// Замени класс _MyApplicationsTab в profile_page.dart на этот

class _MyApplicationsTab extends StatelessWidget {
  const _MyApplicationsTab();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Не авторизован'));

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
            child: Text('У вас пока нет заявок',
                style: AppTypography.h3.copyWith(color: AppColors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, i) {
            final doc = snap.data!.docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            final isAccepted = status == 'accepted';

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
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(data['projectTitle'] ?? 'Проект',
                            style: AppTypography.h3),
                      ),
                      _StatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xs),
                  if (data['role'] != null)
                    Text(data['role'],
                        style: AppTypography.caption
                            .copyWith(color: AppColors.primary)),
                  const SizedBox(height: AppSizes.sm),
                  Text(data['motivation'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body),
                  const SizedBox(height: AppSizes.md),

                  // Кнопка отзыва — для pending и accepted
                  if (status == 'pending' || isAccepted)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmWithdraw(
                          context: context,
                          applicationId: doc.id,
                          isAccepted: isAccepted,
                        ),
                        icon: const Icon(Icons.undo_rounded, size: 16),
                        label: Text(isAccepted
                            ? 'Покинуть проект'
                            : 'Отозвать заявку'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          minimumSize:
                              const Size(0, AppSizes.buttonHeight - 8),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmWithdraw({
    required BuildContext context,
    required String applicationId,
    required bool isAccepted,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        title: Text(isAccepted ? 'Покинуть проект?' : 'Отозвать заявку?'),
        content: Text(isAccepted
            ? 'Вы покинете проект и освободите своё место. Это действие нельзя отменить.'
            : 'Ваша заявка будет удалена. Вы сможете подать заявку снова.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _withdraw(context: context, applicationId: applicationId);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: Text(isAccepted ? 'Покинуть' : 'Отозвать'),
          ),
        ],
      ),
    );
  }

  Future<void> _withdraw({
    required BuildContext context,
    required String applicationId,
  }) async {
    try {
      final db = FirebaseFirestore.instance;

      await db.runTransaction((transaction) async {
        final appRef = db.collection('applications').doc(applicationId);
        final appSnap = await transaction.get(appRef);

        if (!appSnap.exists) throw Exception('Заявка не найдена');

        final data = appSnap.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'pending';
        final projectId = data['projectId'] as String;

        // Если заявка принята — освобождаем слот
        if (status == 'accepted') {
          final projectRef = db.collection('projects').doc(projectId);
          final projectSnap = await transaction.get(projectRef);

          if (projectSnap.exists) {
            final projectData = projectSnap.data() as Map<String, dynamic>;
            final filledField = projectData.containsKey('filledSlots')
                ? 'filledSlots'
                : 'filled_slots';
            final currentFilled = (projectData[filledField] ?? 0) as int;

            if (currentFilled > 0) {
              transaction.update(projectRef,
                  {filledField: FieldValue.increment(-1)});
            }
          }
        }

        // Удаляем заявку
        transaction.delete(appRef);
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Заявка отозвана'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}

// ─── FIRESTORE STATUS UPDATE ─────────────────────────────────────────────

Future<void> _updateApplicationStatus({
  required BuildContext context,
  required DocumentReference applicationRef,
  required bool accept,
}) async {
  try {
    final db = FirebaseFirestore.instance;
    await db.runTransaction((transaction) async {
      final appSnap = await transaction.get(applicationRef);
      if (!appSnap.exists) throw Exception('Заявка не найдена');

      final appData = appSnap.data() as Map<String, dynamic>;
      if ((appData['status'] ?? 'pending') != 'pending') return;

      if (accept) {
        final projectId = appData['projectId'] as String;
        final projectRef = db.collection('projects').doc(projectId);
        final projectSnap = await transaction.get(projectRef);
        if (!projectSnap.exists) throw Exception('Проект не найден');

        final projectData = projectSnap.data() as Map<String, dynamic>;
        final filledField = projectData.containsKey('filledSlots')
            ? 'filledSlots'
            : 'filled_slots';
        final totalField = projectData.containsKey('totalSlots')
            ? 'totalSlots'
            : 'total_slots';
        final filledSlots = (projectData[filledField] ?? 0) as int;
        final totalSlots = (projectData[totalField] ?? 0) as int;

        if (filledSlots >= totalSlots) {
          throw Exception('Свободных мест больше нет');
        }

        transaction.update(
            projectRef, {filledField: FieldValue.increment(1)});
        transaction.update(applicationRef, {
          'status': 'accepted',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.update(applicationRef, {
          'status': 'rejected',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(accept ? 'Заявка принята' : 'Заявка отклонена')));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ошибка: $e'), backgroundColor: AppColors.error));
  }
}

// ─── WIDGETS ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case 'accepted':
      case 'approved':
        color = AppColors.success;
        text = 'Принято';
        break;
      case 'rejected':
        color = AppColors.error;
        text = 'Отклонено';
        break;
      default:
        color = AppColors.primary;
        text = 'На рассмотрении';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style:
                    AppTypography.caption.copyWith(color: AppColors.grey)),
          ),
          Expanded(child: Text(value, style: AppTypography.body)),
        ],
      ),
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