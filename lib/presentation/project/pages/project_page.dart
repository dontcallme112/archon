import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/project_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/project/project_usecases.dart';
import '../../../domain/repositories/firestore_project_repository.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class ProjectPage extends StatelessWidget {
  final String projectId;
  const ProjectPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectBloc(
        getProject: GetProjectByIdUseCase(FirestoreProjectRepository()),
        toggleFavorite: ToggleFavoriteUseCase(FirestoreProjectRepository()),
      )..add(ProjectLoadRequested(projectId)),
      child: const _ProjectPageView(),
    );
  }
}

class _ProjectPageView extends StatelessWidget {
  const _ProjectPageView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state.status == ProjectStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == ProjectStatus.error || state.project == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: AppSizes.md),
                  Text(state.errorMessage ?? 'Проект не найден',
                      style: AppTypography.body),
                  const SizedBox(height: AppSizes.md),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Назад'),
                  ),
                ],
              ),
            ),
          );
        }

        final project = state.project!;
        return _ProjectContent(project: project, isSaved: state.isSaved);
      },
    );
  }
}

class _ProjectContent extends StatelessWidget {
  final ProjectEntity project;
  final bool isSaved;
  const _ProjectContent({required this.project, required this.isSaved});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isSaved ? AppColors.primary : AppColors.dark,
                ),
                onPressed: () =>
                    context.read<ProjectBloc>().add(ProjectSaveToggled()),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBadge.active(),
                  const SizedBox(height: AppSizes.sm),

                  Text(project.title, style: AppTypography.h1),
                  const SizedBox(height: AppSizes.md),

                  Text(
                    project.fullDescription,
                    style: AppTypography.body.copyWith(color: AppColors.darkGrey),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  _InfoCard(children: [
                    _InfoRow(
                      icon: Icons.psychology_rounded,
                      label: 'Навыки',
                      value: project.requiredSkills.join(', '),
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Дедлайн',
                      value: project.deadline,
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.people_rounded,
                      label: 'Команда',
                      value:
                          'Уже в команде: ${project.filledSlots} из ${project.totalSlots}',
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.laptop_rounded,
                      label: 'Формат',
                      value: project.format,
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.signal_cellular_alt_rounded,
                      label: 'Уровень',
                      value: project.level,
                    ),
                  ]),
                  const SizedBox(height: AppSizes.md),

                  SectionHeader(title: 'Нужные навыки'),
                  const SizedBox(height: AppSizes.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: project.requiredSkills
                        .map((s) => SkillChip(label: s))
                        .toList(),
                  ),
                  const SizedBox(height: AppSizes.md),

                  if (project.teamMembers.isNotEmpty) ...[
                    SectionHeader(title: 'Команда'),
                    const SizedBox(height: AppSizes.sm),
                    ...project.teamMembers.map((m) => _TeamMemberTile(user: m)),
                    const SizedBox(height: AppSizes.md),
                  ],

                  _InfoCard(
                    children: [
                      Row(
                        children: [
                          AppAvatar(name: project.author.name, size: 40),
                          const SizedBox(width: AppSizes.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Автор', style: AppTypography.caption),
                              Text(project.author.name, style: AppTypography.h4),
                            ],
                          ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 36),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('Написать'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.sm,
          AppSizes.md,
          AppSizes.sm + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: AppColors.dark.withOpacity(0.08), blurRadius: 16)
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () =>
              context.push('/project/${project.id}/apply'),
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Откликнуться'),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(color: AppColors.dark.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption),
                Text(value, style: AppTypography.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberTile extends StatelessWidget {
  final UserEntity user;
  const _TeamMemberTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        children: [
          AppAvatar(name: user.name, imageUrl: user.avatarUrl, size: 36),
          const SizedBox(width: AppSizes.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: AppTypography.h4),
              if (user.skills.isNotEmpty)
                Text(user.skills.take(2).join(', '),
                    style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }
}