import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/entities.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class ProjectPage extends StatefulWidget {
  final String projectId;
  const ProjectPage({super.key, required this.projectId});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  bool _isSaved = false;

  // Mock project
  ProjectEntity get _project => ProjectEntity(
        id: widget.projectId,
        title: 'Redesign приложения для фитнеса',
        shortDescription: 'Создаём интуитивный UX для трекера тренировок.',
        fullDescription:
            'Подробное описание проекта: цели, задачи, текущий этап... полюбить гипотезы о теориях прохожих проекта. Итоговые зазвали нас самым разным людям. Подробное описание проектов: цели, задачи, текущий этап...',
        requiredSkills: ['UI/UX', 'Figma', 'Мобильная разработка', 'UX Research'],
        deadline: '15 мая 2024',
        format: 'Онлайн',
        level: 'middle',
        totalSlots: 5,
        filledSlots: 2,
        author: const UserEntity(id: 'u1', name: 'Иван Иванов', skills: [], level: 'middle'),
        teamMembers: const [
          UserEntity(id: 'u2', name: 'Мария К.', skills: [], level: 'middle'),
          UserEntity(id: 'u3', name: 'Алексей П.', skills: [], level: 'junior'),
        ],
        category: 'Дизайн',
        isActive: true,
        createdAt: DateTime.now(),
      );

  @override
  Widget build(BuildContext context) {
    final project = _project;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
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
                  _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: _isSaved ? AppColors.primary : AppColors.dark,
                ),
                onPressed: () => setState(() => _isSaved = !_isSaved),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  StatusBadge.active(),
                  const SizedBox(height: AppSizes.sm),

                  // Title
                  Text(project.title, style: AppTypography.h1),
                  const SizedBox(height: AppSizes.md),

                  // Description
                  Text(project.fullDescription, style: AppTypography.body.copyWith(color: AppColors.darkGrey)),
                  const SizedBox(height: AppSizes.lg),

                  // Info section
                  _InfoCard(
                    children: [
                      _InfoRow(icon: Icons.psychology_rounded, label: 'Навыки', value: project.requiredSkills.join(', ')),
                      const Divider(),
                      _InfoRow(icon: Icons.calendar_today_rounded, label: 'Сроки', value: '3 месяца. Дедлайн: ${project.deadline}'),
                      const Divider(),
                      _InfoRow(icon: Icons.people_rounded, label: 'Команда', value: 'Уже в команде: ${project.filledSlots} человека'),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Skills chips
                  SectionHeader(title: 'Нужные навыки'),
                  const SizedBox(height: AppSizes.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: project.requiredSkills.map((s) => SkillChip(label: s)).toList(),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Team
                  SectionHeader(title: 'Команда'),
                  const SizedBox(height: AppSizes.sm),
                  ...project.teamMembers.map((m) => _TeamMemberTile(user: m)),
                  const SizedBox(height: AppSizes.md),

                  // Author
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
                              padding: const EdgeInsets.symmetric(horizontal: 12),
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
          boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(0.08), blurRadius: 16)],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_down_outlined, size: 18),
                label: const Text('Откликнуться'),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/project/${widget.projectId}/apply'),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Откликнуться'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSizes.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption),
              Text(value, style: AppTypography.body),
            ],
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
              Text(user.skills.take(2).join(', '), style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }
}