import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/entities.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class ApplicationsManagementPage extends StatefulWidget {
  final String projectId;
  const ApplicationsManagementPage({super.key, required this.projectId});

  @override
  State<ApplicationsManagementPage> createState() =>
      _ApplicationsManagementPageState();
}

class _ApplicationsManagementPageState
    extends State<ApplicationsManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<ApplicationEntity> _applications;

  @override
  void initState() {
    super.initState();
    _applications = _mockApplications();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ApplicationEntity> get _pending =>
      _applications.where((a) => a.status == ApplicationStatus.pending).toList();
  List<ApplicationEntity> get _accepted =>
      _applications.where((a) => a.status == ApplicationStatus.accepted).toList();
  List<ApplicationEntity> get _rejected =>
      _applications.where((a) => a.status == ApplicationStatus.rejected).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────────────
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(AppSizes.sm, AppSizes.sm, AppSizes.md, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(child: Text('Мои проекты', style: AppTypography.h3)),
                    ],
                  ),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.grey,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2,
                    labelStyle: AppTypography.label,
                    tabs: [
                      Tab(text: 'Кандидаты (${_pending.length})'),
                      Tab(text: 'Принятые (${_accepted.length})'),
                      Tab(text: 'Отклонённые'),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Tabs ─────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AppList(
                    apps: _pending,
                    projectId: widget.projectId,
                    emptyIcon: Icons.hourglass_empty_rounded,
                    emptyLabel: 'Нет новых заявок',
                    onAccept: _accept,
                    onReject: _reject,
                  ),
                  _AppList(
                    apps: _accepted,
                    projectId: widget.projectId,
                    emptyIcon: Icons.people_outline_rounded,
                    emptyLabel: 'Никто ещё не принят',
                    onAccept: _accept,
                    onReject: _reject,
                  ),
                  _AppList(
                    apps: _rejected,
                    projectId: widget.projectId,
                    emptyIcon: Icons.block_rounded,
                    emptyLabel: 'Нет отклонённых',
                    onAccept: _accept,
                    onReject: _reject,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _accept(ApplicationEntity app) {
    setState(() {
      _applications = _applications.map((a) {
        if (a.id == app.id) return _withStatus(a, ApplicationStatus.accepted);
        return a;
      }).toList();
    });
    _showSnack('${app.applicant.name} принят в команду! ✓', AppColors.success);
  }

  void _reject(ApplicationEntity app) {
    setState(() {
      _applications = _applications.map((a) {
        if (a.id == app.id) return _withStatus(a, ApplicationStatus.rejected);
        return a;
      }).toList();
    });
    _showSnack('Заявка отклонена', AppColors.error);
  }

  ApplicationEntity _withStatus(ApplicationEntity a, ApplicationStatus s) =>
      ApplicationEntity(
        id: a.id,
        projectId: a.projectId,
        projectTitle: a.projectTitle,
        applicant: a.applicant,
        role: a.role,
        skills: a.skills,
        portfolioUrl: a.portfolioUrl,
        motivation: a.motivation,
        status: s,
        createdAt: a.createdAt,
      );

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: AppColors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        margin: const EdgeInsets.all(AppSizes.md),
      ),
    );
  }
}

// ─── App list ─────────────────────────────────────────────────────────────

class _AppList extends StatelessWidget {
  final List<ApplicationEntity> apps;
  final String projectId;
  final IconData emptyIcon;
  final String emptyLabel;
  final void Function(ApplicationEntity) onAccept;
  final void Function(ApplicationEntity) onReject;

  const _AppList({
    required this.apps,
    required this.projectId,
    required this.emptyIcon,
    required this.emptyLabel,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: AppColors.lightGrey),
            const SizedBox(height: AppSizes.md),
            Text(emptyLabel,
                style: AppTypography.h3.copyWith(color: AppColors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: apps.length,
      itemBuilder: (context, i) => _AppCard(
        app: apps[i],
        projectId: projectId,
        onAccept: () => onAccept(apps[i]),
        onReject: () => onReject(apps[i]),
      ),
    );
  }
}

// ─── App card ─────────────────────────────────────────────────────────────

class _AppCard extends StatelessWidget {
  final ApplicationEntity app;
  final String projectId;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _AppCard({
    required this.app,
    required this.projectId,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = app.status == ApplicationStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        onTap: () =>
            context.push('/project/$projectId/applications/${app.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Applicant info
              Row(
                children: [
                  AppAvatar(
                      name: app.applicant.name,
                      imageUrl: app.applicant.avatarUrl,
                      size: 46),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.applicant.name, style: AppTypography.h4),
                        Text(app.role,
                            style: AppTypography.body
                                .copyWith(color: AppColors.primary)),
                        Text('краткое описание',
                            style: AppTypography.caption),
                      ],
                    ),
                  ),
                  // Status icon for non-pending
                  if (!isPending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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
                        style: AppTypography.caption.copyWith(
                          color: app.status == ApplicationStatus.accepted
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),

              // Skills
              if (app.skills.isNotEmpty) ...[
                Text('навыки', style: AppTypography.caption),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: app.skills
                      .take(4)
                      .map((s) => SkillChip(label: s))
                      .toList(),
                ),
              ],

              // Action buttons (pending only)
              if (isPending) ...[
                const SizedBox(height: AppSizes.sm),
                const Divider(height: 1),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'Принять',
                        icon: Icons.check_rounded,
                        color: AppColors.success,
                        onTap: onAccept,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Отклонить',
                        icon: Icons.close_rounded,
                        color: AppColors.error,
                        onTap: onReject,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Написать',
                        icon: Icons.chat_bubble_outline_rounded,
                        color: AppColors.grey,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: AppTypography.caption
                    .copyWith(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Mock data ────────────────────────────────────────────────────────────

List<ApplicationEntity> _mockApplications() {
  const users = [
    UserEntity(id: 'u2', name: 'Екатерина Соловьева', skills: ['React', 'Node.js', 'TypeScript'], level: 'middle'),
    UserEntity(id: 'u3', name: 'Дмитрий Козлов', skills: ['Flutter', 'Dart', 'Firebase'], level: 'junior'),
    UserEntity(id: 'u4', name: 'Анна Белова', skills: ['Figma', 'UI/UX', 'Prototyping'], level: 'middle'),
    UserEntity(id: 'u5', name: 'Сергей Новиков', skills: ['Python', 'ML/AI', 'TensorFlow'], level: 'senior'),
  ];
  return [
    ApplicationEntity(id: 'a1', projectId: 'p1', projectTitle: 'Redesign фитнес', applicant: users[0], role: 'React-разработчик', skills: users[0].skills, motivation: 'Хочу получить опыт...', status: ApplicationStatus.pending, createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    ApplicationEntity(id: 'a2', projectId: 'p1', projectTitle: 'Redesign фитнес', applicant: users[1], role: 'Flutter-разработчик', skills: users[1].skills, motivation: 'Разрабатываю приложения...', status: ApplicationStatus.pending, createdAt: DateTime.now().subtract(const Duration(hours: 5))),
    ApplicationEntity(id: 'a3', projectId: 'p1', projectTitle: 'Redesign фитнес', applicant: users[2], role: 'UI/UX Дизайнер', skills: users[2].skills, motivation: 'Люблю создавать интерфейсы...', status: ApplicationStatus.accepted, createdAt: DateTime.now().subtract(const Duration(days: 1))),
    ApplicationEntity(id: 'a4', projectId: 'p1', projectTitle: 'Redesign фитнес', applicant: users[3], role: 'ML-инженер', skills: users[3].skills, motivation: 'Работаю с ML 3 года...', status: ApplicationStatus.rejected, createdAt: DateTime.now().subtract(const Duration(days: 2))),
  ];
}