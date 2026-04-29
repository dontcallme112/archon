import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/core/reference/app_reference_data.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 0;
  final Set<String> _selectedSkills = {};
  String _selectedLevel = 'junior';
  final _portfolioController = TextEditingController();

  @override
  void dispose() {
    _portfolioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.lg),
              Text(
                'Добро пожаловать!\nДавайте настроим ваш профиль.',
                style: AppTypography.h2,
              ),
              const SizedBox(height: AppSizes.sm),
              Text('Шаг ${_step + 1}/3', style: AppTypography.caption),
              const SizedBox(height: AppSizes.lg),
              _StepIndicator(currentStep: _step),
              const SizedBox(height: AppSizes.lg),
              Expanded(child: _buildStep()),
              const SizedBox(height: AppSizes.md),
              PrimaryButton(
                label: _step < 2 ? 'Продолжить' : 'Начать',
                icon: _step < 2
                    ? Icons.arrow_forward_rounded
                    : Icons.rocket_launch_rounded,
                onTap: _next,
              ),
              const SizedBox(height: AppSizes.sm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _SkillsStep(
          selected: _selectedSkills,
          onToggle: (s) => setState(() {
            _selectedSkills.contains(s)
                ? _selectedSkills.remove(s)
                : _selectedSkills.add(s);
          }),
        );
      case 1:
        return _LevelStep(
          selected: _selectedLevel,
          onSelect: (l) => setState(() => _selectedLevel = l),
        );
      case 2:
        return _PortfolioStep(controller: _portfolioController);
      default:
        return const SizedBox();
    }
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      context.go('/feed');
    }
  }
}

// ─── Step indicator ───────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i <= currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Step 1: Навыки ───────────────────────────────────────────────────────

class _SkillsStep extends StatefulWidget {
  final Set<String> selected;
  final void Function(String) onToggle;

  const _SkillsStep({required this.selected, required this.onToggle});

  @override
  State<_SkillsStep> createState() => _SkillsStepState();
}

class _SkillsStepState extends State<_SkillsStep> {
  // Активная категория — по умолчанию первая
  String _activeCategoryId = AppCategories.all.first.id;

  @override
  Widget build(BuildContext context) {
    final skills = AppSkills.byCategory(_activeCategoryId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Выбери навыки', style: AppTypography.h3),
        const SizedBox(height: AppSizes.xs),
        Text(
          'Выбери то, что умеешь или хочешь развивать',
          style: AppTypography.body.copyWith(color: AppColors.grey),
        ),
        const SizedBox(height: AppSizes.md),

        // Категории — горизонтальный скролл
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: AppCategories.all.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = AppCategories.all[i];
              final isActive = cat.id == _activeCategoryId;
              return GestureDetector(
                onTap: () => setState(() => _activeCategoryId = cat.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.lightGrey,
                    ),
                  ),
                  child: Text(
                    cat.label,
                    style: AppTypography.caption.copyWith(
                      color: isActive ? Colors.white : AppColors.dark,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSizes.md),

        // Навыки выбранной категории
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.selected.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: Text(
                      'Выбрано: ${widget.selected.length}',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map((s) => SkillChip(
                            label: s.label,
                            isSelected: widget.selected.contains(s.id),
                            onTap: () => widget.onToggle(s.id),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Step 2: Уровень ──────────────────────────────────────────────────────

class _LevelStep extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  const _LevelStep({required this.selected, required this.onSelect});

  static const _descriptions = {
    'intern': 'Только начинаю, ищу первый опыт',
    'junior': 'Есть базовые знания, ищу практику',
    'middle': 'Есть опыт, готов к реальным задачам',
    'senior': 'Опытный, могу вести проект',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Твой уровень', style: AppTypography.h3),
        const SizedBox(height: AppSizes.xs),
        Text(
          'Это поможет найти подходящие проекты',
          style: AppTypography.body.copyWith(color: AppColors.grey),
        ),
        const SizedBox(height: AppSizes.md),
        ...AppLevels.all.map((lvl) {
          final isSelected = selected == lvl.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: GestureDetector(
              onTap: () => onSelect(lvl.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.08)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.lightGrey,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: lvl.id,
                      groupValue: selected,
                      onChanged: (v) => onSelect(v!),
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lvl.label, style: AppTypography.h4),
                        Text(
                          _descriptions[lvl.id] ?? '',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Step 3: Портфолио ────────────────────────────────────────────────────

class _PortfolioStep extends StatelessWidget {
  final TextEditingController controller;
  const _PortfolioStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Добавь портфолио', style: AppTypography.h3),
        const SizedBox(height: AppSizes.xs),
        Text(
          'Это необязательно, но повысит шансы быть принятым в проект',
          style: AppTypography.body.copyWith(color: AppColors.grey),
        ),
        const SizedBox(height: AppSizes.md),
        AppTextField(
          hint: 'behance.net/username',
          label: 'Ссылка на портфолио',
          controller: controller,
          prefixIcon: const Icon(Icons.link_rounded, color: AppColors.grey),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: AppSizes.md),
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  'Можно добавить позже в профиле',
                  style:
                      AppTypography.body.copyWith(color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}