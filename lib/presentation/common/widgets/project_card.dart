import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/entities.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class ProjectCard extends StatefulWidget {
  final ProjectEntity project;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  const ProjectCard({
    super.key,
    required this.project,
    this.isFavorite = false,
    this.onFavorite,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _controller.reverse(),
        onTapUp: (_) {
          _controller.forward();
          context.push('/project/${project.id}');
        },
        onTapCancel: () => _controller.forward(),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.md),
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
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
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
                Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(project.title, style: AppTypography.h3, maxLines: 2),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        project.shortDescription,
                        style: AppTypography.body.copyWith(
                          color: AppColors.darkGrey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Skills
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: project.requiredSkills
                            .take(4)
                            .map((s) => SkillChip(label: s))
                            .toList(),
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Footer: team + deadline + apply
                      Row(
                        children: [
                          // Team avatars
                          _TeamAvatars(members: project.teamMembers),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            '${project.filledSlots}/${project.totalSlots} мест свободно',
                            style: AppTypography.caption,
                          ),
                          const Spacer(),
                          DeadlineBadge(deadline: project.deadline),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (FirebaseAuth.instance.currentUser == null) {
                              context.push('/register');
                              return;
                            }
                            context.push('/project/${project.id}/apply');
                          },
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: const Text('Откликнуться'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamAvatars extends StatelessWidget {
  final List<UserEntity> members;
  const _TeamAvatars({required this.members});

  @override
  Widget build(BuildContext context) {
    final show = members.take(3).toList();
    return SizedBox(
      width: show.length * 22.0 + 18,
      height: 28,
      child: Stack(
        children: show.asMap().entries.map((e) {
          return Positioned(
            left: e.key * 18.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: AppAvatar(
                name: e.value.name,
                imageUrl: e.value.avatarUrl,
                size: 24,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
