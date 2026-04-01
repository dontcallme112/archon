import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets/common_widgets.dart';
import '../bloc/feed_bloc.dart';
import '../widgets/project_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(),
            _CategoryFilters(),
            _FormatFilters(),
            const SizedBox(height: AppSizes.xs),
            const Expanded(child: _ProjectList()),
          ],
        ),
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.md, AppSizes.md, 0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              style: AppTypography.body,
              onChanged: (v) =>
                  context.read<FeedBloc>().add(FeedSearchChanged(v)),
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
    );
  }
}

// ─── Category filters ─────────────────────────────────────────────────────

class _CategoryFilters extends StatelessWidget {
  static const _categories = [
    'Все', 'Дизайн', 'Разработка', 'Маркетинг'
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      buildWhen: (p, c) => p.activeCategory != c.activeCategory,
      builder: (context, state) {
        return SizedBox(
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
                isSelected: state.activeCategory == cat,
                onTap: () => context
                    .read<FeedBloc>()
                    .add(FeedCategoryChanged(cat)),
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Format filters ───────────────────────────────────────────────────────

class _FormatFilters extends StatelessWidget {
  static const _formats = ['Все', 'Онлайн', 'Оффлайн'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      buildWhen: (p, c) => p.activeFormat != c.activeFormat,
      builder: (context, state) {
        return SizedBox(
          height: 32,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md),
            scrollDirection: Axis.horizontal,
            itemCount: _formats.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSizes.sm),
            itemBuilder: (context, i) {
              final fmt = _formats[i];
              final isActive = state.activeFormat == fmt;
              return GestureDetector(
                onTap: () => context
                    .read<FeedBloc>()
                    .add(FeedFormatChanged(fmt)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.dark
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(
                        AppSizes.radiusFull),
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
        );
      },
    );
  }
}

// ─── Project list ─────────────────────────────────────────────────────────

class _ProjectList extends StatelessWidget {
  const _ProjectList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        switch (state.status) {
          case FeedStatus.initial:
          case FeedStatus.loading:
            return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary),
            );

          case FeedStatus.error:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 64, color: AppColors.lightGrey),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    state.errorMessage ?? 'Ошибка загрузки',
                    style: AppTypography.body
                        .copyWith(color: AppColors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.md),
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<FeedBloc>()
                        .add(FeedRefreshRequested()),
                    icon: const Icon(Icons.refresh_rounded,
                        size: 18),
                    label: const Text('Повторить'),
                  ),
                ],
              ),
            );

          case FeedStatus.loaded:
            if (state.projects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off_rounded,
                        size: 64, color: AppColors.lightGrey),
                    const SizedBox(height: AppSizes.md),
                    Text('Пока нет проектов 😕',
                        style: AppTypography.h3
                            .copyWith(color: AppColors.grey)),
                    const SizedBox(height: AppSizes.sm),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/project/create'),
                      icon: const Icon(Icons.add_rounded,
                          size: 18),
                      label: const Text('Создать проект'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => context
                  .read<FeedBloc>()
                  .add(FeedRefreshRequested()),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md),
                itemCount: state.projects.length,
                itemBuilder: (context, i) {
                  final project = state.projects[i];
                  return ProjectCard(
                    project: project,
                    isFavorite: state.isFavorite(project.id),
                    onFavorite: () => context
                        .read<FeedBloc>()
                        .add(FeedFavoriteToggled(project.id)),
                  );
                },
              ),
            );
        }
      },
    );
  }
}
