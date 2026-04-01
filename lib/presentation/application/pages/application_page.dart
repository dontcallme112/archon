import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class ApplicationPage extends StatefulWidget {
  final String projectId;
  const ApplicationPage({super.key, required this.projectId});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'Алексей Петров');
  final _telegramController = TextEditingController(text: '@alex_petrov_tg');
  final _portfolioController = TextEditingController(text: 'behance.net/alex_petrov');
  final _motivationController = TextEditingController();

  String _selectedRole = 'UI/UX Дизайнер';
  final Set<String> _selectedSkills = {'UI/UX', 'Figma', 'Prototyping'};

  final _roles = ['UI/UX Дизайнер', 'Frontend', 'Backend', 'iOS', 'Android', 'Маркетолог', 'SMM', 'Другое'];
  final _availableSkills = ['Figma', 'Sketch', 'UI/UX', 'Prototyping', 'Flutter', 'React', 'Python', 'Node.js', 'Marketing'];

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Подача заявки'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Шаг ${_step + 1}/2: ${_step == 0 ? "Информация" : "Мотивация"}',
                      style: AppTypography.caption),
                  const SizedBox(height: 6),
                  Row(
                    children: [0, 1].map((i) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i == 0 ? 6 : 0),
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= _step ? AppColors.primary : AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.md),
                child: _step == 0 ? _buildStep1() : _buildStep2(),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.sm + MediaQuery.of(context).padding.bottom,
              ),
              child: PrimaryButton(
                label: _step == 0 ? 'Далее' : 'Отправить заявку',
                icon: _step == 0 ? Icons.arrow_forward_rounded : Icons.send_rounded,
                isLoading: _isSubmitting,
                onTap: _step == 0 ? _nextStep : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(hint: 'Алексей Петров', label: 'Имя', controller: _nameController),
        const SizedBox(height: AppSizes.md),
        AppTextField(hint: '@username', label: 'Контакт (TG)', controller: _telegramController,
          prefixIcon: const Icon(Icons.telegram, color: AppColors.grey)),
        const SizedBox(height: AppSizes.md),

        // Role picker
        Text('Роль (выбор)', style: AppTypography.label),
        const SizedBox(height: AppSizes.xs),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.primarySurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 12),
          ),
          items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r, style: AppTypography.body))).toList(),
          onChanged: (v) => setState(() => _selectedRole = v!),
        ),
        const SizedBox(height: AppSizes.md),

        // Skills
        Text('Навыки (чипсы)', style: AppTypography.label),
        const SizedBox(height: AppSizes.xs),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _availableSkills
              .map((s) => SkillChip(
                    label: s,
                    isSelected: _selectedSkills.contains(s),
                    onTap: () => setState(() {
                      _selectedSkills.contains(s) ? _selectedSkills.remove(s) : _selectedSkills.add(s);
                    }),
                  ))
              .toList(),
        ),
        const SizedBox(height: AppSizes.md),

        AppTextField(
          hint: 'behance.net/username',
          label: 'Портфолио (ссылка)',
          controller: _portfolioController,
          prefixIcon: const Icon(Icons.link_rounded, color: AppColors.grey),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Мотивация', style: AppTypography.h3),
        const SizedBox(height: AppSizes.xs),
        Text(
          'Расскажи, почему ты хочешь участвовать в этом проекте',
          style: AppTypography.body.copyWith(color: AppColors.grey),
        ),
        const SizedBox(height: AppSizes.md),
        AppTextField(
          hint: 'Хочу получить опыт в реальных проектах...',
          label: 'Мотивация (1 поле)',
          controller: _motivationController,
          maxLines: 6,
          validator: (v) => (v == null || v.isEmpty) ? 'Обязательное поле' : null,
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
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  'Опиши свой опыт и что хочешь получить от проекта',
                  style: AppTypography.body.copyWith(color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _nextStep() {
    setState(() => _step = 1);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isSubmitting = false);
      _showSuccess();
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 36),
            ),
            const SizedBox(height: AppSizes.md),
            Text('Заявка отправлена!', style: AppTypography.h3),
            const SizedBox(height: AppSizes.xs),
            Text('Создатель рассмотрит её и ответит вам', style: AppTypography.body.copyWith(color: AppColors.grey), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: const Text('Отлично!'),
          ),
        ],
      ),
    );
  }
}