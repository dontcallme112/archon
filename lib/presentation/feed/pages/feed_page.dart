import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_app/presentation/common/widgets/project_card.dart';

import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../domain/entities/entities.dart';

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

  Stream<List<ProjectEntity>> _buildStream() {
    Query q = FirebaseFirestore.instance
        .collection('projects')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (_activeCategory != 'Все') {
      q = q.where('category', isEqualTo: _activeCategory);
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
            requiredSkills: List<String>.from(d['skills'] ?? []),
            deadline: d['deadline'] ?? '',
            format: d['format'] ?? 'Онлайн',
            level: d['level'] ?? 'junior',
            totalSlots: d['slots'] ?? 0,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.md, AppSizes.md, AppSizes.md, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      style: AppTypography.body,
                      decoration: InputDecoration(
                        hintText: 'Поиск',
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.grey, size: 20),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: const Icon(Icons.tune_rounded,
                          color: AppColors.dark, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: 2),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSizes.sm),
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

            const SizedBox(height: 6),

            SizedBox(
              height: 32,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSizes.md),
                scrollDirection: Axis.horizontal,
                itemCount: _formats.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSizes.sm),
                itemBuilder: (context, i) {
                  final fmt = _formats[i];
                  final isActive = _activeFormat == fmt;
                  return GestureDetector(
                    onTap: () => setState(() => _activeFormat = fmt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            isActive ? AppColors.dark : AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        fmt,
                        style: AppTypography.caption.copyWith(
                          color: isActive
                              ? AppColors.white
                              : AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSizes.sm),

            Expanded(
              child: StreamBuilder<List<ProjectEntity>>(
                stream: _buildStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Ошибка: ${snapshot.error}'));
                  }
                  final projects = snapshot.data ?? [];
                  if (projects.isEmpty) return _EmptyFeed();

                  return RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSizes.md),
                      itemCount: projects.length,
                      itemBuilder: (context, i) => ProjectCard(
                        project: projects[i],
                      ),
                    ),
                  );
                },
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text('Проектов пока нет',
                style: AppTypography.h2,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Будь первым — создай проект\nи собери свою команду',
              style: AppTypography.body
                  .copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xl),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/project/create'),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Создать проект'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}