import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/entities.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class ProjectCard extends StatefulWidget {
  final ProjectEntity project;

  const ProjectCard({super.key, required this.project});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final slotsLeft = project.totalSlots - project.filledSlots;
    final isFull = slotsLeft <= 0;

    return ScaleTransition(
      scale: _controller,
      child: GestureDetector(
        onTapDown: (_) => _controller.reverse(),
        onTapUp: (_) {
          _controller.forward();
          context.push('/project/${project.id}');
        },
        onTapCancel: () => _controller.forward(),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.md),

          // 💙 ВНЕШНЯЯ "рамка"
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primary.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),

          // 💎 ВНУТРЕННЯЯ карточка
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dark.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppColors.dark.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Категория + уровень ──
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
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isFull
                              ? const Color(0xFFFFEBEE)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isFull
                              ? 'Мест нет'
                              : '$slotsLeft ${_slotsLabel(slotsLeft)}',
                          style: AppTypography.caption.copyWith(
                            color:
                                isFull ? AppColors.error : AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // ── Заголовок ──
                  Text(
                    project.title,
                    style: AppTypography.h3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // ── Описание ──
                  Text(
                    project.shortDescription,
                    style: AppTypography.body.copyWith(
                      color: AppColors.darkGrey,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // ── Навыки ──
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

                  const Divider(height: 1),
                  const SizedBox(height: AppSizes.sm),

                  // ── Footer ──
                  Row(
                    children: [
                      if (project.teamMembers.isNotEmpty) ...[
                        _TeamAvatars(members: project.teamMembers),
                        const SizedBox(width: AppSizes.sm),
                      ],
                      DeadlineBadge(deadline: project.deadline),
                      const Spacer(),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: () => context
                              .push('/project/${project.id}/apply'),
                          icon: const Icon(Icons.send_rounded, size: 14),
                          label: const Text('Откликнуться'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _slotsLabel(int n) {
    if (n == 1) return 'место';
    if (n >= 2 && n <= 4) return 'места';
    return 'мест';
  }
}

// ── Тег (категория / уровень) ────────────────────────────────────────────

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

// ── Аватары команды ──────────────────────────────────────────────────────

class _TeamAvatars extends StatelessWidget {
  final List<UserEntity> members;
  const _TeamAvatars({required this.members});

  @override
  Widget build(BuildContext context) {
    final show = members.take(3).toList();
    return SizedBox(
      width: show.length * 20.0 + 16,
      height: 26,
      child: Stack(
        children: show.asMap().entries.map((e) {
          return Positioned(
            left: e.key * 16.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: AppAvatar(
                name: e.value.name,
                imageUrl: e.value.avatarUrl,
                size: 22,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}