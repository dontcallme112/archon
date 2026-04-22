import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/domain/repositories/firestore_project_repository.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  int _step = 0;
  bool _isPublishing = false;
  bool _autosaved = false;

  // Step 1
  final _titleController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _fullDescController = TextEditingController();

  // Step 2
  final Set<String> _selectedSkills = {};
  int _slots = 3;
  DateTime? _deadline;
  String _format = 'Онлайн';
  String _level = 'junior';

  final _availableSkills = [
    'Figma', 'UI/UX', 'Sketch', 'Flutter',
    'React', 'Node.js', 'Python', 'iOS',
    'Android', 'Marketing', 'SMM', 'ML/AI',
  ];
  final _formats = ['Онлайн', 'Оффлайн'];
  final _levels = ['junior', 'middle', 'senior'];

  bool get _step1Valid =>
      _titleController.text.trim().isNotEmpty &&
      _shortDescController.text.trim().isNotEmpty;

  bool get _step2Valid => _selectedSkills.isNotEmpty && _deadline != null;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onStep1Changed);
    _shortDescController.addListener(_onStep1Changed);
    _fullDescController.addListener(_onStep1Changed);
  }

  void _onStep1Changed() {
    if (_titleController.text.isNotEmpty) {
      setState(() => _autosaved = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _fullDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────────────
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm, vertical: AppSizes.xs),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    onPressed: () {
                      if (_step > 0) {
                        setState(() => _step--);
                      } else {
                        context.pop();
                      }
                    },
                  ),
                  Expanded(
                    child: Text('Новый проект', style: AppTypography.h3),
                  ),
                  if (_autosaved)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_done_rounded,
                            size: 14, color: AppColors.success),
                        const SizedBox(width: 3),
                        Text('Автосохранение',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.success)),
                        const SizedBox(width: AppSizes.sm),
                      ],
                    ),
                ],
              ),
            ),

            // ─── Step indicator ───────────────────────────────────
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.md, 0, AppSizes.md, AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Шаг ${_step + 1}/2: ${_step == 0 ? "Основное" : "Параметры"}',
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
                            borderRadius: BorderRadius.circular(
                                AppSizes.radiusFull),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // ─── Form ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.md),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _step == 0
                      ? _Step1(
                          key: const ValueKey(0),
                          titleController: _titleController,
                          shortDescController: _shortDescController,
                          fullDescController: _fullDescController,
                        )
                      : _Step2(
                          key: const ValueKey(1),
                          availableSkills: _availableSkills,
                          selectedSkills: _selectedSkills,
                          formats: _formats,
                          levels: _levels,
                          slots: _slots,
                          format: _format,
                          level: _level,
                          deadline: _deadline,
                          onSkillToggle: (s) => setState(() {
                            _selectedSkills.contains(s)
                                ? _selectedSkills.remove(s)
                                : _selectedSkills.add(s);
                          }),
                          onSlotsDecrement: () =>
                              setState(() => _slots = (_slots - 1).clamp(1, 50)),
                          onSlotsIncrement: () =>
                              setState(() => _slots++),
                          onFormatChanged: (v) =>
                              setState(() => _format = v),
                          onLevelChanged: (v) =>
                              setState(() => _level = v),
                          onDeadlineTap: _pickDeadline,
                        ),
                ),
              ),
            ),

            // ─── Bottom button ────────────────────────────────────
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
                      offset: const Offset(0, -3))
                ],
              ),
              child: PrimaryButton(
                label: _step == 0 ? 'Далее' : 'Опубликовать проект',
                icon: _step == 0
                    ? Icons.arrow_forward_rounded
                    : Icons.rocket_launch_rounded,
                isLoading: _isPublishing,
                onTap: _step == 0 ? _nextStep : _publish,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    if (!_step1Valid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Заполни название и краткое описание'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        margin: const EdgeInsets.all(AppSizes.md),
      ));
      return;
    }
    setState(() => _step = 1);
  }

Future<void> _publish() async {
  if (!_step2Valid) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Выбери навыки и дедлайн'),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      margin: const EdgeInsets.all(AppSizes.md),
    ));
    return;
  }
  setState(() => _isPublishing = true);

  try {
    final repo = FirestoreProjectRepository();
    final deadline = _deadline!;

    await repo.createProject(
      title: _titleController.text.trim(),
      shortDescription: _shortDescController.text.trim(),
      fullDescription: _fullDescController.text.trim(),
      skills: _selectedSkills.toList(),
      slots: _slots,
      deadline: '${deadline.day}.${deadline.month}.${deadline.year}',
      format: _format,
      level: _level,
    );

    if (!mounted) return;
    setState(() => _isPublishing = false);
    _showSuccess();
  } catch (e) {
    if (!mounted) return;
    setState(() => _isPublishing = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ошибка: $e'),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      margin: const EdgeInsets.all(AppSizes.md),
    ));
  }
}

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Icon(Icons.rocket_launch_rounded,
                  color: AppColors.success, size: 36),
            ),
            const SizedBox(height: AppSizes.md),
            Text('Проект опубликован! 🚀', style: AppTypography.h3,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Твой проект теперь виден в ленте',
              style: AppTypography.body.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/feed');
              },
              child: const Text('Перейти в ленту'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1 ───────────────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController shortDescController;
  final TextEditingController fullDescController;

  const _Step1({
    super.key,
    required this.titleController,
    required this.shortDescController,
    required this.fullDescController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          hint: 'Название проекта',
          label: 'Название проекта',
          controller: titleController,
          validator: (v) =>
              v == null || v.isEmpty ? 'Обязательное поле' : null,
        ),
        const SizedBox(height: AppSizes.md),
        AppTextField(
          hint: 'Короткое описание (превью для карточки)',
          label: 'Короткое описание (превью для карточки)',
          controller: shortDescController,
          maxLines: 3,
        ),
        const SizedBox(height: AppSizes.md),
        AppTextField(
          hint: 'Подробно опиши цели, задачи и ожидаемый результат',
          label: 'Полное описание',
          controller: fullDescController,
          maxLines: 6,
        ),
        const SizedBox(height: AppSizes.md),
        // Hint
        Container(
          padding: const EdgeInsets.all(AppSizes.sm + 4),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  'Хорошее описание повышает шансы найти команду. Расскажи о целях и стеке.',
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

// ─── Step 2 ───────────────────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final List<String> availableSkills;
  final Set<String> selectedSkills;
  final List<String> formats;
  final List<String> levels;
  final int slots;
  final String format;
  final String level;
  final DateTime? deadline;
  final void Function(String) onSkillToggle;
  final VoidCallback onSlotsDecrement;
  final VoidCallback onSlotsIncrement;
  final void Function(String) onFormatChanged;
  final void Function(String) onLevelChanged;
  final VoidCallback onDeadlineTap;

  const _Step2({
    super.key,
    required this.availableSkills,
    required this.selectedSkills,
    required this.formats,
    required this.levels,
    required this.slots,
    required this.format,
    required this.level,
    required this.deadline,
    required this.onSkillToggle,
    required this.onSlotsDecrement,
    required this.onSlotsIncrement,
    required this.onFormatChanged,
    required this.onLevelChanged,
    required this.onDeadlineTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skills
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Навыки (кого ищешь)', style: AppTypography.label),
            if (selectedSkills.isNotEmpty)
              Text('${selectedSkills.length} выбрано',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: AppSizes.xs),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: availableSkills
              .map((s) => SkillChip(
                    label: s,
                    isSelected: selectedSkills.contains(s),
                    onTap: () => onSkillToggle(s),
                  ))
              .toList(),
        ),
        const SizedBox(height: AppSizes.md),

        // Slots counter
        Text('Кол-во людей', style: AppTypography.label),
        const SizedBox(height: AppSizes.xs),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onSlotsDecrement,
                icon: const Icon(Icons.remove_rounded),
                color: AppColors.primary,
              ),
              Expanded(
                child: Text(
                  '$slots ${_plural(slots)}',
                  textAlign: TextAlign.center,
                  style: AppTypography.h3,
                ),
              ),
              IconButton(
                onPressed: onSlotsIncrement,
                icon: const Icon(Icons.add_rounded),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),

        // Deadline
        Text('Дедлайн', style: AppTypography.label),
        const SizedBox(height: AppSizes.xs),
        GestureDetector(
          onTap: onDeadlineTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: 14),
            decoration: BoxDecoration(
              color: deadline != null
                  ? AppColors.primarySurface
                  : AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: deadline != null
                    ? AppColors.primary
                    : AppColors.lightGrey,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: deadline != null
                      ? AppColors.primary
                      : AppColors.grey,
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  deadline != null
                      ? '${deadline!.day}.${deadline!.month}.${deadline!.year}'
                      : 'Выбрать дату',
                  style: AppTypography.body.copyWith(
                    color: deadline != null
                        ? AppColors.primary
                        : AppColors.grey,
                    fontWeight: deadline != null
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (deadline != null) ...[
                  const Spacer(),
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: AppColors.success),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),

        // Format + Level
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DropdownBlock(
                label: 'Формат (онлайн/оффлайн)',
                value: format,
                items: formats,
                onChanged: onFormatChanged,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _DropdownBlock(
                label: 'Уровень участников',
                value: level,
                items: levels,
                displayMap: {
                  'junior': 'Junior',
                  'middle': 'Middle',
                  'senior': 'Senior'
                },
                onChanged: onLevelChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _plural(int n) {
    if (n == 1) return 'человек';
    if (n >= 2 && n <= 4) return 'человека';
    return 'человек';
  }
}

class _DropdownBlock extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final void Function(String) onChanged;
  final Map<String, String>? displayMap;

  const _DropdownBlock({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.displayMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label, maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: AppSizes.xs),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.primarySurface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
          items: items
              .map((i) => DropdownMenuItem(
                    value: i,
                    child: Text(
                      displayMap?[i] ?? i,
                      style: AppTypography.body,
                    ),
                  ))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }
}