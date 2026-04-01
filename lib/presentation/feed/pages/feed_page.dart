import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/presentation/common/widgets/project_card.dart';
import '../../../domain/entities/entities.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  String _activeCategory = 'Все';
  String _activeFormat = 'Все';
  final _searchController = TextEditingController();

  final _categories = ['Все', 'Дизайн', 'Разработка', 'Маркетинг'];
  final _formats = ['Все', 'Онлайн', 'Оффлайн'];

  // Mock data
  final _projects = _mockProjects();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      style: AppTypography.body,
                      decoration: InputDecoration(
                        hintText: 'Поиск',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.grey, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Icon(Icons.tune_rounded, color: AppColors.dark, size: 20),
                  ),
                ],
              ),
            ),

            // Category filters
            const SizedBox(height: AppSizes.sm),
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  return SkillChip(
                    label: cat,
                    isSelected: _activeCategory == cat,
                    onTap: () => setState(() => _activeCategory = cat),
                  );
                },
              ),
            ),

            // Format filters
            const SizedBox(height: 6),
            SizedBox(
              height: 32,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                scrollDirection: Axis.horizontal,
                itemCount: _formats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final fmt = _formats[i];
                  return GestureDetector(
                    onTap: () => setState(() => _activeFormat = fmt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _activeFormat == fmt ? AppColors.dark : AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        fmt,
                        style: AppTypography.caption.copyWith(
                          color: _activeFormat == fmt ? AppColors.white : AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSizes.sm),

            // Projects list
            Expanded(
              child: _projects.isEmpty
                  ? _EmptyFeed()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      itemCount: _projects.length,
                      itemBuilder: (context, i) => ProjectCard(
                        project: _projects[i],
                        isFavorite: false,
                        onFavorite: () {},
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.lightGrey),
          const SizedBox(height: AppSizes.md),
          Text('Пока нет проектов 😕', style: AppTypography.h3.copyWith(color: AppColors.grey)),
          const SizedBox(height: AppSizes.sm),
          TextButton.icon(
            onPressed: () => context.push('/project/create'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Создать проект'),
          ),
        ],
      ),
    );
  }
}

// ─── Mock Data ────────────────────────────────────────────────────────────────

List<ProjectEntity> _mockProjects() {
  final author = const UserEntity(
    id: 'u1',
    name: 'Иван Иванов',
    skills: ['UI/UX', 'Figma'],
    level: 'middle',
  );

  return [
    ProjectEntity(
      id: 'p1',
      title: 'Redesign приложения для фитнеса',
      shortDescription: 'Создаём интуитивный UX для трекера тренировок и питания.',
      fullDescription: 'Подробное описание проекта: цели, задачи, текущий этап... полюбить гипотезы о теориях прохожих проекта, не разозлившись на прототип проекта, хотелось и постройте правила...',
      requiredSkills: ['UI/UX', 'Figma', 'Мобильная разработка', 'UX Research'],
      deadline: '15 мая 2024',
      format: 'Онлайн',
      level: 'middle',
      totalSlots: 5,
      filledSlots: 3,
      author: author,
      teamMembers: [author],
      category: 'Дизайн',
      isActive: true,
      createdAt: DateTime.now(),
    ),
    ProjectEntity(
      id: 'p2',
      title: 'AI Стартап — студенческий проект',
      shortDescription: 'Разрабатываем AI-инструмент для автоматизации учёбы.',
      fullDescription: 'Ищем разработчиков и дизайнеров для создания MVP нашего стартапа.',
      requiredSkills: ['Python', 'ML/AI', 'React', 'UI/UX'],
      deadline: '1 июня 2024',
      format: 'Онлайн',
      level: 'junior',
      totalSlots: 6,
      filledSlots: 2,
      author: author,
      teamMembers: [author],
      category: 'Разработка',
      isActive: true,
      createdAt: DateTime.now(),
    ),
  ];
}