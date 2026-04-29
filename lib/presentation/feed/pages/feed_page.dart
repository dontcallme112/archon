import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/core/reference/app_reference_data.dart';
import 'package:student_app/presentation/common/widgets/project_card.dart';
import 'package:student_app/presentation/feed/bloc/feed_bloc.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FeedBloc>().add(FeedLoadRequested());
    return const _FeedView();
  }
}

class _FeedView extends StatelessWidget {
  const _FeedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: const _FeedBody(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Text('ProjectHub', style: AppTypography.h2),
      actions: [
        BlocBuilder<FeedBloc, FeedState>(
          buildWhen: (prev, curr) =>
              prev.hasActiveFilters != curr.hasActiveFilters,
          builder: (context, state) {
            return IconButton(
              tooltip: 'Фильтры',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.tune_rounded, color: AppColors.dark),
                  if (state.hasActiveFilters)
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
              onPressed: () => _showFilterSheet(context),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    final bloc = context.read<FeedBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const _FilterSheet(),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────

class _FeedBody extends StatelessWidget {
  const _FeedBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        if (state.status == FeedStatus.loading && state.projects.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == FeedStatus.error && state.projects.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.errorMessage ?? 'Что-то пошло не так',
                    style:
                        AppTypography.body.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.md),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FeedBloc>().add(FeedRefreshRequested()),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          );
        }

        final projects = state.projects;

        if (projects.isEmpty && state.status == FeedStatus.loaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                const _HeroSection(),
                const SizedBox(height: AppSizes.md),
                _ActiveFiltersRow(state: state),
                const SizedBox(height: AppSizes.xl),
                _EmptyState(
                  onCreateTap: () => context.push('/project/create'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              context.read<FeedBloc>().add(FeedRefreshRequested()),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            // +1 для Hero, +1 для кнопки «Загрузить ещё»
            itemCount: projects.length + 2,
            itemBuilder: (context, i) {
              // Hero + активные фильтры
              if (i == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeroSection(),
                    const SizedBox(height: AppSizes.md),
                    _ActiveFiltersRow(state: state),
                  ],
                );
              }

              // Карточки проектов
              if (i <= projects.length) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.md),
                  child: ProjectCard(project: projects[i - 1]),
                );
              }

              // Кнопка «Загрузить ещё» / индикатор / конец списка
              return _LoadMoreButton(state: state);
            },
          ),
        );
      },
    );
  }
}

// ─── Кнопка «Загрузить ещё» ───────────────────────────────────────────────

class _LoadMoreButton extends StatelessWidget {
  final FeedState state;
  const _LoadMoreButton({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status == FeedStatus.loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
        child: Center(
          child: Text(
            'Все проекты загружены',
            style: AppTypography.caption.copyWith(color: AppColors.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.lg, top: AppSizes.sm),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: () =>
              context.read<FeedBloc>().add(FeedLoadMoreRequested()),
          icon: const Icon(Icons.expand_more_rounded, size: 18),
          label: const Text('Загрузить ещё'),
        ),
      ),
    );
  }
}

// ─── Активные фильтры-чипы ────────────────────────────────────────────────

class _ActiveFiltersRow extends StatelessWidget {
  final FeedState state;
  const _ActiveFiltersRow({required this.state});

  String _categoryLabel(String id) =>
      AppCategories.all.firstWhere((c) => c.id == id,
          orElse: () => CategoryItem(
              id: id, label: id, firestoreValue: id, icon: '', order: 0)).label;

  String _formatLabel(String id) =>
      AppFormats.all.firstWhere((f) => f.id == id,
          orElse: () =>
              ReferenceItem(id: id, label: id, firestoreValue: id, order: 0)).label;

  String _levelLabel(String id) =>
      AppLevels.all.firstWhere((l) => l.id == id,
          orElse: () =>
              ReferenceItem(id: id, label: id, firestoreValue: id, order: 0)).label;

  @override
  Widget build(BuildContext context) {
    if (!state.hasActiveFilters) return const SizedBox.shrink();

    final bloc = context.read<FeedBloc>();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (state.activeCategory != null)
            Chip(
              label: Text(_categoryLabel(state.activeCategory!)),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => bloc.add(FeedCategoryChanged(null)),
            ),
          if (state.activeFormat != null)
            Chip(
              label: Text(_formatLabel(state.activeFormat!)),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => bloc.add(FeedFormatChanged(null)),
            ),
          if (state.activeLevel != null)
            Chip(
              label: Text(_levelLabel(state.activeLevel!)),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => bloc.add(FeedLevelChanged(null)),
            ),
          ActionChip(
            label: const Text(
              'Сбросить всё',
              style: TextStyle(fontSize: 13, color: AppColors.dark),
            ),
            backgroundColor: AppColors.background,
            side: const BorderSide(color: AppColors.grey, width: 1),
            onPressed: () => bloc.add(FeedFiltersCleared()),
          ),
        ],
      ),
    );
  }
}

// ─── Filter bottom sheet ───────────────────────────────────────────────────

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        final bloc = context.read<FeedBloc>();
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20, 16, 20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Фильтры', style: AppTypography.h3),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text('Формат', style: AppTypography.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: 'Все',
                      selected: state.activeFormat == null,
                      onTap: () => bloc.add(FeedFormatChanged(null)),
                    ),
                    ...AppFormats.all.map((fmt) => _FilterChip(
                          label: fmt.label,
                          selected: state.activeFormat == fmt.id,
                          onTap: () => bloc.add(FeedFormatChanged(fmt.id)),
                        )),
                  ],
                ),
                const SizedBox(height: 16),

                Text('Уровень', style: AppTypography.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: 'Все',
                      selected: state.activeLevel == null,
                      onTap: () => bloc.add(FeedLevelChanged(null)),
                    ),
                    ...AppLevels.all.map((lvl) => _FilterChip(
                          label: lvl.label,
                          selected: state.activeLevel == lvl.id,
                          onTap: () => bloc.add(FeedLevelChanged(lvl.id)),
                        )),
                  ],
                ),
                const SizedBox(height: 16),

                Text('Категория', style: AppTypography.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: 'Все',
                      selected: state.activeCategory == null,
                      onTap: () => bloc.add(FeedCategoryChanged(null)),
                    ),
                    ...AppCategories.all.map((cat) => _FilterChip(
                          label: cat.label,
                          selected: state.activeCategory == cat.id,
                          onTap: () => bloc.add(FeedCategoryChanged(cat.id)),
                        )),
                  ],
                ),
                const SizedBox(height: 20),

                if (state.hasActiveFilters)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        bloc.add(FeedFiltersCleared());
                        Navigator.pop(context);
                      },
                      child: const Text('Сбросить все фильтры'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: selected ? Colors.white : AppColors.dark,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.grey,
        width: 1,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────

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