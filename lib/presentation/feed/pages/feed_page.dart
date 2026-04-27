import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/presentation/common/widgets/project_card.dart';
import '../../../domain/entities/entities.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

// ─── Категории ────────────────────────────────────────────────────────────

const List<Map<String, dynamic>> kProjectCategories = [
  {'label': 'Все',        'value': null},
  {'label': 'Дизайн',     'value': 'Дизайн'},
  {'label': 'Разработка', 'value': 'Разработка'},
  {'label': 'Маркетинг',  'value': 'Маркетинг'},
  {'label': 'Аналитика',  'value': 'Аналитика'},
  {'label': 'Менеджмент', 'value': 'Менеджмент'},
  {'label': 'Другое',     'value': 'Другое'},
];

// ─── FeedPage ─────────────────────────────────────────────────────────────

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  String? _selectedCategory; // null = все
  String _activeFormat = 'Все';

  final _formats = ['Все', 'Онлайн', 'Оффлайн'];

  // ✅ Firestore стрим с фильтрами
  Stream<List<ProjectEntity>> get _projectsStream {
    Query q = FirebaseFirestore.instance
        .collection('projects')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (_selectedCategory != null) {
      q = q.where('category', isEqualTo: _selectedCategory);
    }
    if (_activeFormat != 'Все') {
      q = q.where('format', isEqualTo: _activeFormat);
    }

    return q.snapshots().map((snap) => snap.docs.map((doc) {
          final d = doc.data() as Map<String, dynamic>;
          return ProjectEntity(
            id: doc.id,
            title: d['title'] ?? '',
            shortDescription: d['shortDescription'] ?? '',
            fullDescription: d['fullDescription'] ?? '',
            requiredSkills: List<String>.from(
                d['requiredSkills'] ?? d['skills'] ?? []),
            deadline: d['deadline'] ?? '',
            format: d['format'] ?? 'Онлайн',
            level: d['level'] ?? 'junior',
            totalSlots: d['totalSlots'] ?? 0,
            filledSlots: d['filledSlots'] ?? 0,
            author: UserEntity(
              id: d['authorId'] ?? '',
              name: d['authorName'] ?? '',
              avatarUrl: d['authorAvatar'],
              skills: [],
              level: 'junior',
            ),
            teamMembers: [],
            category: d['category'] ?? 'Разработка',
            isActive: d['isActive'] ?? true,
            createdAt:
                (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList());
  }

  bool get _hasActiveFilters =>
      _selectedCategory != null || _activeFormat != 'Все';

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Фильтры', style: AppTypography.h3),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  // Формат
                  Text('Формат', style: AppTypography.label),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _formats.map((fmt) {
                      final isSelected = _activeFormat == fmt;
                      return ChoiceChip(
                        label: Text(fmt),
                        selected: isSelected,
                        onSelected: (_) {
                          setSheetState(() {});
                          setState(() => _activeFormat = fmt);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Категория
                  Text('Категория', style: AppTypography.label),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kProjectCategories.map((cat) {
                      final isSelected = _selectedCategory == cat['value'];
                      return ChoiceChip(
                        label: Text(cat['label'] as String),
                        selected: isSelected,
                        onSelected: (_) {
                          setSheetState(() {});
                          setState(() =>
                              _selectedCategory = cat['value'] as String?);
                          Navigator.pop(ctx);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ─── AppBar ──────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text('ProjectHub', style: AppTypography.h2),
        actions: [
          // Кнопка фильтров с индикатором
          IconButton(
            tooltip: 'Фильтры',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.tune_rounded, color: AppColors.dark),
                if (_hasActiveFilters)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterSheet,
          ),
          // Кнопка профиля
          IconButton(
            tooltip: 'Профиль',
            icon: const Icon(Icons.person_rounded, color: AppColors.dark),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ─── Body ────────────────────────────────────────────────
      body: StreamBuilder<List<ProjectEntity>>(
        stream: _projectsStream,
        builder: (context, snapshot) {
          // Загрузка
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Ошибка
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(
                  'Ошибка: ${snapshot.error}',
                  style: AppTypography.body.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final projects = snapshot.data ?? [];

          // Активные фильтры-чипы
          final activeFiltersRow = _hasActiveFilters
              ? Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (_selectedCategory != null)
                        Chip(
                          label: Text(_selectedCategory!),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () =>
                              setState(() => _selectedCategory = null),
                        ),
                      if (_activeFormat != 'Все')
                        Chip(
                          label: Text(_activeFormat),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () =>
                              setState(() => _activeFormat = 'Все'),
                        ),
                    ],
                  ),
                )
              : const SizedBox.shrink();

          // Пусто
          if (projects.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                children: [
                  const _HeroSection(),
                  const SizedBox(height: AppSizes.md),
                  activeFiltersRow,
                  const SizedBox(height: AppSizes.xl),
                  _EmptyState(onCreateTap: () => context.push('/project/create')),
                ],
              ),
            );
          }

          // ✅ Список проектов
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.md),
              // +1 для Hero+фильтры в первом элементе
              itemCount: projects.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HeroSection(),
                      const SizedBox(height: AppSizes.md),
                      activeFiltersRow,
                    ],
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.md),
                  child: ProjectCard(project: projects[i - 1]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ─── Hero секция ──────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Найди свою команду',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Платформа для поиска стажировок и участия в реальных проектах. '
            'Присоединяйся к командам, прокачивай навыки и строй портфолио.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onPrimary.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyState({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.folder_open_rounded,
              size: 48, color: AppColors.primary),
        ),
        const SizedBox(height: AppSizes.lg),
        Text('Проектов пока нет',
            style: AppTypography.h2, textAlign: TextAlign.center),
        const SizedBox(height: AppSizes.sm),
        Text(
          'Будь первым — создай проект\nи собери свою команду',
          style: AppTypography.body.copyWith(color: AppColors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.xl),
        SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Создать проект'),
          ),
        ),
      ],
    );
  }
}