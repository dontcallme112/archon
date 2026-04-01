import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/entities.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class ApplicationDetailsPage extends StatefulWidget {
  final String projectId;
  final String applicationId;

  const ApplicationDetailsPage({
    super.key,
    required this.projectId,
    required this.applicationId,
  });

  @override
  State<ApplicationDetailsPage> createState() => _ApplicationDetailsPageState();
}

class _ApplicationDetailsPageState extends State<ApplicationDetailsPage> {
  late ApplicationEntity _application;

  @override
  void initState() {
    super.initState();
    _application = _mockApplication(widget.applicationId);
  }

  bool get _isPending => _application.status == ApplicationStatus.pending;

  @override
  Widget build(BuildContext context) {
    final app = _application;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── AppBar ───────────────────────────────────────────
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm, vertical: AppSizes.xs),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Заявка от:', style: AppTypography.caption),
                        Text(app.applicant.name, style: AppTypography.h3),
                      ],
                    ),
                  ),
                  // Status badge
                  if (!_isPending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: app.status == ApplicationStatus.accepted
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        app.status == ApplicationStatus.accepted
                            ? '✓ Принят'
                            : '✗ Отклонён',
                        style: AppTypography.label.copyWith(
                          color: app.status == ApplicationStatus.accepted
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ─── Content ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar card
                    _AvatarCard(user: app.applicant),
                    const SizedBox(height: AppSizes.md),

                    // Info fields
                    _InfoCard(children: [
                      _Field(label: 'Имя', value: app.applicant.name),
                      const Divider(height: 1),
                      _Field(
                        label: 'Контакт (TG)',
                        value: app.applicant.telegram ?? '—',
                        isHighlight: true,
                      ),
                      const Divider(height: 1),
                      _Field(label: 'Роль (выбор)', value: app.role),
                    ]),
                    const SizedBox(height: AppSizes.md),

                    // Skills
                    _SectionLabel(label: 'Навыки (чипсы)'),
                    const SizedBox(height: AppSizes.xs),
                    _InfoCard(
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: app.skills
                              .map((s) => SkillChip(label: s))
                              .toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Portfolio
                    _InfoCard(children: [
                      _Field(
                        label: 'Портфолио (ссылка)',
                        value: app.portfolioUrl ?? '—',
                        isLink: app.portfolioUrl != null,
                      ),
                    ]),
                    const SizedBox(height: AppSizes.md),

                    // Motivation
                    _SectionLabel(label: 'Мотивация (1 поле)'),
                    const SizedBox(height: AppSizes.xs),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.dark.withOpacity(0.04),
                              blurRadius: 6)
                        ],
                      ),
                      child: Text(app.motivation, style: AppTypography.body),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Search by skills bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              size: 18, color: AppColors.grey),
                          const SizedBox(width: AppSizes.sm),
                          Text('Поиск по навыкам, названию...',
                              style: AppTypography.body
                                  .copyWith(color: AppColors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),

                    // Filters row (visual only)
                    Row(
                      children: [
                        Expanded(child: _FilterPill(label: 'Навыки')),
                        const SizedBox(width: 6),
                        Expanded(
                            child: _FilterPill(
                                label: 'Дедлайн', icon: Icons.calendar_today_rounded)),
                        const SizedBox(width: 6),
                        Expanded(
                            child: _FilterPill(
                                label: 'Формат', hasDropdown: true)),
                        const SizedBox(width: 6),
                        Expanded(
                            child: _FilterPill(
                                label: 'Уровень', hasDropdown: true)),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ),

            // ─── Bottom action bar ────────────────────────────────
            if (_isPending)
              Container(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.md,
                  AppSizes.sm,
                  AppSizes.md,
                  AppSizes.sm + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.dark.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _accept,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                minimumSize: const Size(0, 48)),
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text('Принять'),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _reject,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                minimumSize: const Size(0, 48)),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: const Text('Отклонить'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 18),
                        label: const Text('Написать'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _accept() {
    setState(() {
      _application = _withStatus(ApplicationStatus.accepted);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${_application.applicant.name} принят в команду! ✓'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      margin: const EdgeInsets.all(AppSizes.md),
    ));
  }

  void _reject() {
    setState(() {
      _application = _withStatus(ApplicationStatus.rejected);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Заявка отклонена'),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      margin: const EdgeInsets.all(AppSizes.md),
    ));
  }

  ApplicationEntity _withStatus(ApplicationStatus s) => ApplicationEntity(
        id: _application.id,
        projectId: _application.projectId,
        projectTitle: _application.projectTitle,
        applicant: _application.applicant,
        role: _application.role,
        skills: _application.skills,
        portfolioUrl: _application.portfolioUrl,
        motivation: _application.motivation,
        status: s,
        createdAt: _application.createdAt,
      );

  ApplicationEntity _mockApplication(String id) => ApplicationEntity(
        id: id,
        projectId: widget.projectId,
        projectTitle: 'Redesign фитнес-приложения',
        applicant: const UserEntity(
          id: 'u2',
          name: 'Алексей Петров',
          telegram: '@alex_petrov_tg',
          skills: ['Figma', 'Sketch', 'Prototyping'],
          level: 'middle',
          portfolioUrl: 'behance.net/alex_petrov',
        ),
        role: 'UI/UX Дизайнер',
        skills: const ['Figma', 'Sketch', 'Prototyping'],
        portfolioUrl: 'behance.net/alex_petrov',
        motivation:
            'Хочу получить опыт в реальных проектах. Уже 2 года занимаюсь дизайном, делал проекты для учёбы, но хочу поработать в команде над настоящим продуктом.',
        status: ApplicationStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      );
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────

class _AvatarCard extends StatelessWidget {
  final UserEntity user;
  const _AvatarCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
              color: AppColors.dark.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          AppAvatar(name: user.name, imageUrl: user.avatarUrl, size: 60),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: AppTypography.h3),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        user.level,
                        style: AppTypography.caption.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
              color: AppColors.dark.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final bool isLink;
  final bool isHighlight;

  const _Field({
    required this.label,
    required this.value,
    this.isLink = false,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.body.copyWith(
              color: isLink
                  ? AppColors.primary
                  : isHighlight
                      ? AppColors.primary
                      : AppColors.dark,
              decoration: isLink ? TextDecoration.underline : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) =>
      Text(label, style: AppTypography.label);
}

class _FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool hasDropdown;

  const _FilterPill({
    required this.label,
    this.icon,
    this.hasDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: AppColors.grey),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(label,
                style: AppTypography.caption,
                overflow: TextOverflow.ellipsis),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 14, color: AppColors.grey),
          ],
        ],
      ),
    );
  }
} 