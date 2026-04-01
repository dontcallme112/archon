import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  int _step = 0; // 0, 1, 2
  final Set<String> _selectedSkills = {};
  String _selectedLevel = 'junior';
  final _portfolioController = TextEditingController();

  final _availableSkills = [
    'Figma', 'Sketch', 'UI/UX', 'Prototyping',
    'Flutter', 'React', 'Node.js', 'Python',
    'Marketing', 'SMM', 'Copywriting', 'Analytics',
    'iOS', 'Android', 'DevOps', 'ML/AI',
  ];

  final _levels = ['junior', 'middle', 'senior'];

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
              // Header
              Text(
                'Добро пожаловать!\nДавайте настроим ваш профиль.',
                style: AppTypography.h2,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Шаг ${_step + 1}/3',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSizes.lg),

              // Step indicator
              _StepIndicator(currentStep: _step),
              const SizedBox(height: AppSizes.lg),

              Expanded(child: _buildStep()),

              const SizedBox(height: AppSizes.md),
              PrimaryButton(
                label: _step < 2 ? 'Продолжить' : 'Начать',
                icon: _step < 2 ? Icons.arrow_forward_rounded : Icons.rocket_launch_rounded,
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
          available: _availableSkills,
          selected: _selectedSkills,
          onToggle: (s) => setState(() {
            _selectedSkills.contains(s) ? _selectedSkills.remove(s) : _selectedSkills.add(s);
          }),
        );
      case 1:
        return _LevelStep(
          levels: _levels,
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

class _SkillsStep extends StatelessWidget {
  final List<String> available;
  final Set<String> selected;
  final void Function(String) onToggle;

  const _SkillsStep({
    required this.available,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Выбери навыки', style: AppTypography.h3),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Выбери то, что умеешь или хочешь развивать',
            style: AppTypography.body.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: available
                .map((s) => SkillChip(
                      label: s,
                      isSelected: selected.contains(s),
                      onTap: () => onToggle(s),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LevelStep extends StatelessWidget {
  final List<String> levels;
  final String selected;
  final void Function(String) onSelect;

  const _LevelStep({required this.levels, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final labels = {'junior': 'Junior', 'middle': 'Middle', 'senior': 'Senior'};
    final descriptions = {
      'junior': 'Только начинаю, ищу опыт',
      'middle': 'Есть опыт, готов к реальным задачам',
      'senior': 'Опытный, могу вести проект',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Твой уровень', style: AppTypography.h3),
        const SizedBox(height: AppSizes.sm),
        Text('Это поможет найти подходящие проекты', style: AppTypography.body.copyWith(color: AppColors.grey)),
        const SizedBox(height: AppSizes.md),
        ...levels.map((l) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: GestureDetector(
                onTap: () => onSelect(l),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: selected == l ? AppColors.primary.withOpacity(0.08) : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: selected == l ? AppColors.primary : AppColors.lightGrey,
                      width: selected == l ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: l,
                        groupValue: selected,
                        onChanged: (v) => onSelect(v!),
                        activeColor: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(labels[l]!, style: AppTypography.h4),
                          Text(descriptions[l]!, style: AppTypography.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class _PortfolioStep extends StatelessWidget {
  final TextEditingController controller;
  const _PortfolioStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Добавь портфолио', style: AppTypography.h3),
        const SizedBox(height: AppSizes.sm),
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
              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  'Можно добавить позже в профиле',
                  style: AppTypography.body.copyWith(color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}