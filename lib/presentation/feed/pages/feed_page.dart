import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  // TODO: заменить на Firestore stream
  // Stream<List<ProjectEntity>> get _projectsStream =>
  //     FirebaseFirestore.instance.collection('projects').snapshots()...

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
            // ─── Search bar ────────────────────────────────────
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
                        enabledBorder: OutlineInputBorder(
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

            // ─── Category filters ──────────────────────────────
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

            // ─── Format filters ────────────────────────────────
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

            // ─── Auth banner ───────────────────────────────────
            if (FirebaseAuth.instance.currentUser == null)
              GestureDetector(
                onTap: () => context.push('/register'),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Войди чтобы откликаться на проекты',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),

            // ─── Content ───────────────────────────────────────
            Expanded(child: _EmptyFeed()),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────

class _EmptyFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
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

            Text(
              'Проектов пока нет',
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Будь первым — создай проект\nи собери свою команду',
              style: AppTypography.body.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xl),

            // CTA button
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/project/create'),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Создать проект'),
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // Secondary action
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/search'),
                icon: const Icon(Icons.search_rounded, size: 20),
                label: const Text('Поискать проекты'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
