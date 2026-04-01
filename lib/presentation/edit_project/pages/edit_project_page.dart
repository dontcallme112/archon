import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class EditProjectPage extends StatefulWidget {
  final String projectId;
  const EditProjectPage({super.key, required this.projectId});

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  int _step = 0;
  bool _isSaving = false;
  bool _hasChanges = false;

  // Pre-filled with mock data
  late final TextEditingController _titleController;
  late final TextEditingController _shortDescController;
  late final TextEditingController _fullDescController;

  late Set<String> _selectedSkills;
  late int _slots;
  late String _format;
  late String _level;
  DateTime? _deadline;

  final _availableSkills = [
    'Figma', 'UI/UX', 'Sketch', 'Flutter',
    'React', 'Node.js', 'Python', 'iOS',
    'Android', 'Marketing', 'SMM', 'ML/AI',
  ];
  final _formats = ['Онлайн', 'Оффлайн'];
  final _levels = ['junior', 'middle', 'senior'];

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing project data
    _titleController =
        TextEditingController(text: 'Разработка E-Commerce проекта');
    _shortDescController =
        TextEditingController(text: 'краткое описание проекта');
    _fullDescController = TextEditingController(text: 'Полное описание проекта. Цели, задачи, ожидаемый результат.');
    _selectedSkills = {'React', 'Node.js', 'UI/UX'};
    _slots = 4;
    _format = 'Онлайн';
    _level = 'middle';
    _deadline = DateTime.now().add(const Duration(days: 45));

    _titleController.addListener(_markChanged);
    _shortDescController.addListener(_markChanged);
    _fullDescController.addListener(_markChanged);
  }

  void _markChanged() => setState(() => _hasChanges = true);

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _fullDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // ─── Header ────────────────────────────────────────
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm, vertical: AppSizes.xs),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              size: 20),
                          onPressed: () {
                            if (_step > 0) {
                              setState(() => _step--);
                            } else if (_hasChanges) {
                              _confirmDiscard();
                            } else {
                              context.pop();
                            }
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Редактирование',
                                  style: AppTypography.h3),
                              if (_hasChanges)
                                Text('Есть несохранённые изменения',
                                    style: AppTypography.caption
                                        .copyWith(color: AppColors.warning)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Step indicator
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSizes.md, 4, AppSizes.md, AppSizes.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Шаг ${_step + 1}/2: ${_step == 0 ? "Основное" : "Параметры"} · Редактирование',
                            style: AppTypography.caption,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [0, 1].map((i) {
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: i == 0 ? 6 : 0),
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
                  ],
                ),
              ),

              // ─── Form ───────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _step == 0
                        ? _EditStep1(
                            key: const ValueKey(0),
                            titleController: _titleController,
                            shortDescController: _shortDescController,
                            fullDescController: _fullDescController,
                          )
                        : _EditStep2(
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
                              _hasChanges = true;
                              _selectedSkills.contains(s)
                                  ? _selectedSkills.remove(s)
                                  : _selectedSkills.add(s);
                            }),
                            onSlotsDecrement: () => setState(() {
                              _hasChanges = true;
                              _slots = (_slots - 1).clamp(1, 50);
                            }),
                            onSlotsIncrement: () => setState(() {
                              _hasChanges = true;
                              _slots++;
                            }),
                            onFormatChanged: (v) => setState(() {
                              _hasChanges = true;
                              _format = v;
                            }),
                            onLevelChanged: (v) => setState(() {
                              _hasChanges = true;
                              _level = v;
                            }),
                            onDeadlineTap: _pickDeadline,
                          ),
                  ),
                ),
              ),

              // ─── Bottom buttons ──────────────────────────────────
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
                child: _step == 0
                    ? Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _save,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          color: AppColors.white,
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save_rounded,
                                      size: 18),
                              label: Text(
                                  _isSaving ? 'Сохранение...' : 'Сохранить'),
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, AppSizes.buttonHeight)),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          SizedBox(
                            height: AppSizes.buttonHeight,
                            child: OutlinedButton.icon(
                              onPressed: _confirmDelete,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(
                                    color: AppColors.error),
                                minimumSize:
                                    const Size(0, AppSizes.buttonHeight),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.md),
                              ),
                              icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18),
                              label: const Text('Удалить'),
                            ),
                          ),
                        ],
                      )
                    : PrimaryButton(
                        label: 'Сохранить изменения',
                        icon: Icons.save_rounded,
                        isLoading: _isSaving,
                        onTap: _save,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() { _isSaving = false; _hasChanges = false; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Проект обновлён ✓'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      margin: const EdgeInsets.all(AppSizes.md),
    ));
    if (_step == 0) {
      setState(() => _step = 1);
    } else {
      context.pop();
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
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
    if (picked != null) setState(() { _deadline = picked; _hasChanges = true; });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        title: const Text('Удалить проект?'),
        content: const Text(
            'Это действие нельзя отменить.\nВсе заявки также будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/profile');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Проект удалён'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                margin: const EdgeInsets.all(AppSizes.md),
              ));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _confirmDiscard() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        title: const Text('Отменить изменения?'),
        content: const Text('Несохранённые изменения будут потеряны.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Остаться'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text('Выйти',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Edit Step 1 ──────────────────────────────────────────────────────────

class _EditStep1 extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController shortDescController;
  final TextEditingController fullDescController;

  const _EditStep1({
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
          hint: 'Полное описание',
          label: 'Полное описание',
          controller: fullDescController,
          maxLines: 6,
        ),
      ],
    );
  }
}

// ─── Edit Step 2 ──────────────────────────────────────────────────────────

class _EditStep2 extends StatelessWidget {
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

  const _EditStep2({
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
        Text('Навыки (кого ищешь)', style: AppTypography.label),
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

        Text('Кол-во участников', style: AppTypography.label),
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
                child: Text('$slots чел.',
                    textAlign: TextAlign.center, style: AppTypography.h3),
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

        Text('Дедлайн', style: AppTypography.label),
        const SizedBox(height: AppSizes.xs),
        GestureDetector(
          onTap: onDeadlineTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: deadline != null
                    ? AppColors.primary
                    : AppColors.lightGrey,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 18,
                    color: deadline != null
                        ? AppColors.primary
                        : AppColors.grey),
                const SizedBox(width: AppSizes.sm),
                Text(
                  deadline != null
                      ? '${deadline!.day}.${deadline!.month}.${deadline!.year}'
                      : 'Выбрать дату',
                  style: AppTypography.body.copyWith(
                    color: deadline != null
                        ? AppColors.primary
                        : AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Dropdown(
                label: 'Формат',
                value: format,
                items: formats,
                onChanged: onFormatChanged,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _Dropdown(
                label: 'Уровень',
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
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final void Function(String) onChanged;
  final Map<String, String>? displayMap;

  const _Dropdown({
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
        Text(label, style: AppTypography.label),
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
                    child: Text(displayMap?[i] ?? i,
                        style: AppTypography.body),
                  ))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }
}