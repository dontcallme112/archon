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
                    if (user.portfolioUrl != null &&
                        user.portfolioUrl!.isNotEmpty)
                      Text(
                        user.portfolioUrl!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                        ),
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
            children: [_StatBadge(value: '$projectsCount', label: 'Проектов')],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_open_rounded,
              size: 64,
              color: AppColors.lightGrey,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Нет проектов',
              style: AppTypography.h3.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Создай первый проект',
              style: AppTypography.body.copyWith(color: AppColors.grey),
            ),
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
      itemBuilder: (context, i) {
        final project = projects[i];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _OwnerProjectPage(project: project),
              ),
            );
          },
          child: AbsorbPointer(child: ProjectCard(project: project)),
        );
      },
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Проект'),
              Tab(text: 'Заявки'),
            ],
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
          AbsorbPointer(child: ProjectCard(project: project)),
          const SizedBox(height: AppSizes.md),
          Text('Описание проекта', style: AppTypography.h3),
          const SizedBox(height: AppSizes.sm),
          Text(
            project.fullDescription,
            style: AppTypography.body.copyWith(color: AppColors.darkGrey),
          ),
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
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Заявок пока нет',
              style: AppTypography.h3.copyWith(color: AppColors.grey),
            ),
          );
        }

        final docs = snap.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            final isPending = status == 'pending';

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        _ApplicationDetailsPage(applicationRef: doc.reference),
                  ),
                );
              },
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
                      offset: const Offset(0, 4),
                    ),
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
                          size: 42,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['applicantName'] ?? 'Пользователь',
                                style: AppTypography.h3,
                              ),
                              Text(
                                data['role'] ?? '',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      data['motivation'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body,
                    ),
                    if (isPending) ...[
                      const SizedBox(height: AppSizes.md),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _updateApplicationStatus(
                                context: context,
                                applicationRef: doc.reference,
                                accept: false,
                              ),
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
                                accept: true,
                              ),
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
                            size: 56,
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['applicantName'] ?? 'Пользователь',
                                  style: AppTypography.h2,
                                ),
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
                        label: 'Telegram',
                        value: data['telegram'] ?? '-',
                      ),
                      _InfoRow(
                        label: 'Портфолио',
                        value: data['portfolioUrl'] ?? '-',
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text('Навыки', style: AppTypography.label),
                      const SizedBox(height: AppSizes.xs),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: skills
                            .map((skill) => SkillChip(label: skill))
                            .toList(),
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text('Мотивация', style: AppTypography.label),
                      const SizedBox(height: AppSizes.xs),
                      Text(data['motivation'] ?? '', style: AppTypography.body),
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
                            accept: false,
                          ),
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
                            accept: true,
                          ),
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
            child: Text(
              'У вас пока нет заявок',
              style: AppTypography.h3.copyWith(color: AppColors.grey),
            ),
          );
        }

        final docs = snap.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';

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
                  _StatusBadge(status: status),
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

      if (!appSnap.exists) {
        throw Exception('Заявка не найдена');
      }

      final appData = appSnap.data() as Map<String, dynamic>;
      final currentStatus = appData['status'] ?? 'pending';

      if (currentStatus != 'pending') {
        return;
      }

      if (accept) {
        final projectId = appData['projectId'] as String;
        final projectRef = db.collection('projects').doc(projectId);
        final projectSnap = await transaction.get(projectRef);

        if (!projectSnap.exists) {
          throw Exception('Проект не найден');
        }

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

        transaction.update(projectRef, {filledField: FieldValue.increment(1)});

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(accept ? 'Заявка принята' : 'Заявка отклонена')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка: $e'), backgroundColor: AppColors.error),
    );
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
        text = 'approved';
        break;
      case 'rejected':
        color = AppColors.error;
        text = 'rejected';
        break;
      default:
        color = AppColors.primary;
        text = 'pending';
    }

    return Text(
      'Статус: $text',
      style: AppTypography.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
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
            child: Text(
              label,
              style: AppTypography.caption.copyWith(color: AppColors.grey),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.body)),
        ],
      ),
    );
  }
}

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
