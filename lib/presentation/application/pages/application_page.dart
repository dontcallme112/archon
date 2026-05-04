import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_app/core/reference/app_reference_data.dart';
import 'package:student_app/core/utils/result.dart';

import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../domain/usecases/other_usecases.dart';

class ApplicationPage extends StatefulWidget {
  final String projectId;
  const ApplicationPage({super.key, required this.projectId});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  int _step = 0;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _telegramController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _motivationController = TextEditingController();

  String _selectedRole = 'Frontend';
  final Set<String> _selectedSkillIds = {};
  String _activeCategoryId = AppCategories.all.first.id;

  bool _isSubmitting = false;

  // Показывать ли ошибку навыков
  bool _showSkillsError = false;

  final _roles = [
    'UI/UX Дизайнер',
    'Frontend',
    'Backend',
    'iOS разработчик',
    'Android разработчик',
    'Маркетолог',
    'SMM специалист',
    'Аналитик',
    'Менеджер',
    'Другое',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _telegramController.dispose();
    _portfolioController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              context.pop();
            }
          },
        ),
        title: Text('Подача заявки', style: AppTypography.h3),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.md, 0, AppSizes.md, AppSizes.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Шаг ${_step + 1}/2: ${_step == 0 ? "О себе" : "Мотивация"}',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [0, 1].map((i) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == 0 ? 6 : 0),
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _step
                              ? AppColors.primary
                              : AppColors.lightGrey,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusFull),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: _step == 0 ? _buildStep1() : _buildStep2(),
            ),
          ),
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
                  color: AppColors.dark.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: PrimaryButton(
              label: _step == 0 ? 'Далее' : 'Отправить заявку',
              icon: _step == 0
                  ? Icons.arrow_forward_rounded
                  : Icons.send_rounded,
              isLoading: _isSubmitting,
              onTap: _step == 0 ? _nextStep : _submit,
            ),
          ),
        ],
      ),
    );
  }

  // ── Шаг 1: О себе ────────────────────────────────────────────────────────

  Widget _buildStep1() {
    final skills = AppSkills.byCategory(_activeCategoryId);

    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Имя
          AppTextField(
            label: 'Имя *',
            hint: 'Введите имя',
            controller: _nameController,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Обязательное поле' : null,
          ),
          const SizedBox(height: AppSizes.md),

          // Telegram
          AppTextField(
            label: 'Telegram *',
            hint: '@username',
            controller: _telegramController,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Обязательное поле';
              if (!v.startsWith('@')) return 'Должен начинаться с @';
              return null;
            },
          ),
          const SizedBox(height: AppSizes.md),

          // Роль
          Text('Роль *', style: AppTypography.label),
          const SizedBox(height: AppSizes.xs),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.primarySurface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
            items: _roles
                .map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(r, style: AppTypography.body),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedRole = v!),
          ),
          const SizedBox(height: AppSizes.md),

          // Навыки
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Навыки *', style: AppTypography.label),
              if (_selectedSkillIds.isNotEmpty)
                Text(
                  '${_selectedSkillIds.length} выбрано',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),

          // Категории навыков
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
                  onTap: () =>
                      setState(() => _activeCategoryId = cat.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusFull),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.lightGrey,
                      ),
                    ),
                    child: Text(
                      cat.label,
                      style: AppTypography.caption.copyWith(
                        color: isActive ? Colors.white : AppColors.dark,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map((s) => SkillChip(
                      label: s.label,
                      isSelected: _selectedSkillIds.contains(s.id),
                      onTap: () => setState(() {
                        _showSkillsError = false;
                        _selectedSkillIds.contains(s.id)
                            ? _selectedSkillIds.remove(s.id)
                            : _selectedSkillIds.add(s.id);
                      }),
                    ))
                .toList(),
          ),

          // Ошибка навыков
          if (_showSkillsError)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Выберите хотя бы один навык',
                style: AppTypography.caption
                    .copyWith(color: AppColors.error),
              ),
            ),
          const SizedBox(height: AppSizes.md),

          // Портфолио (необязательно)
          AppTextField(
            label: 'Портфолио',
            hint: 'https://...',
            controller: _portfolioController,
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  // ── Шаг 2: Мотивация ─────────────────────────────────────────────────────

  Widget _buildStep2() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'Расскажи почему ты хочешь присоединиться к этому проекту',
                    style: AppTypography.body
                        .copyWith(color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          AppTextField(
            label: 'Мотивация *',
            hint: 'Почему вы хотите участвовать в этом проекте?',
            controller: _motivationController,
            maxLines: 8,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Обязательное поле';
              if (v.trim().length < 20) {
                return 'Напишите хотя бы 20 символов';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ── Навигация ─────────────────────────────────────────────────────────────

  void _nextStep() {
    final isFormValid = _formKey1.currentState?.validate() ?? false;
    final hasSkills = _selectedSkillIds.isNotEmpty;

    if (!hasSkills) {
      setState(() => _showSkillsError = true);
    }

    if (isFormValid && hasSkills) {
      setState(() => _step = 1);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey2.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final usecase = context.read<SubmitApplicationUseCase>();

    // Конвертируем id навыков → labels
    final skillLabels = _selectedSkillIds
        .map((id) => AppSkills.all
            .firstWhere((s) => s.id == id,
                orElse: () =>
                    SkillItem(id: id, label: id, categoryId: ''))
            .label)
        .toList();

    final result = await usecase(
      projectId: widget.projectId,
      role: _selectedRole,
      skills: skillLabels,
      portfolioUrl: _portfolioController.text.trim().isEmpty
          ? null
          : _portfolioController.text.trim(),
      motivation: _motivationController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    result.fold(
      onSuccess: (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Заявка отправлена! 🚀'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
            margin: const EdgeInsets.all(AppSizes.md),
          ),
        );
        context.pop();
      },
      onFailure: (msg) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
            margin: const EdgeInsets.all(AppSizes.md),
          ),
        );
      },
    );
  }
}