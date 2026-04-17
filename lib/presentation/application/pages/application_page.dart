import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_app/core/utils/result.dart';

import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

import '../../../domain/usecases/other_usecases.dart';

class ApplicationPage extends StatefulWidget {
  final String projectId;
  const ApplicationPage({super.key, required this.projectId});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _telegramController;
  late final TextEditingController _portfolioController;
  final _motivationController = TextEditingController();

  String _selectedRole = 'UI/UX Дизайнер';
  final Set<String> _selectedSkills = {};

  final _roles = [
    'UI/UX Дизайнер',
    'Frontend',
    'Backend',
    'iOS',
    'Android',
    'Маркетолог',
    'SMM',
    'Другое'
  ];

  final _availableSkills = [
    'Figma',
    'Sketch',
    'UI/UX',
    'Prototyping',
    'Flutter',
    'React',
    'Python',
    'Node.js',
    'Marketing'
  ];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _telegramController = TextEditingController();
    _portfolioController = TextEditingController();
  }

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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.md),
                child: _step == 0 ? _buildStep1() : _buildStep2(),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.md,
                AppSizes.sm + MediaQuery.of(context).padding.bottom,
              ),
              child: PrimaryButton(
                label: _step == 0 ? 'Далее' : 'Отправить заявку',
                icon: _step == 0
                    ? Icons.arrow_forward_rounded
                    : Icons.send_rounded,
                isLoading: _isSubmitting,
                onTap: _step == 0
                    ? () => setState(() => _step = 1)
                    : _submit,
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
        AppTextField(
          label: 'Имя',
          hint: 'Введите имя',
          controller: _nameController,
        ),
        const SizedBox(height: AppSizes.md),
        AppTextField(
          label: 'Telegram',
          hint: '@username',
          controller: _telegramController,
        ),
        const SizedBox(height: AppSizes.md),
        DropdownButtonFormField<String>(
          initialValue: _selectedRole,
          items: _roles
              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
              .toList(),
          onChanged: (v) => setState(() => _selectedRole = v!),
        ),
        const SizedBox(height: AppSizes.md),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _availableSkills
              .map(
                (s) => SkillChip(
                  label: s,
                  isSelected: _selectedSkills.contains(s),
                  onTap: () => setState(() {
                    _selectedSkills.contains(s)
                        ? _selectedSkills.remove(s)
                        : _selectedSkills.add(s);
                  }),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSizes.md),
        AppTextField(
          label: 'Портфолио',
          hint: 'https://...',
          controller: _portfolioController,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return AppTextField(
      label: 'Мотивация',
      hint: 'Почему вы хотите в проект',
      controller: _motivationController,
      maxLines: 6,
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Обязательное поле' : null,
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final usecase = context.read<SubmitApplicationUseCase>();

    final result = await usecase(
      projectId: widget.projectId,
      role: _selectedRole,
      skills: _selectedSkills.toList(),
      portfolioUrl: _portfolioController.text.isEmpty
          ? null
          : _portfolioController.text,
      motivation: _motivationController.text,
    );

    setState(() => _isSubmitting = false);

    result.fold(
      onSuccess: (_) {
        if (mounted) context.pop();
      },
      onFailure: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      },
    );
  }
}