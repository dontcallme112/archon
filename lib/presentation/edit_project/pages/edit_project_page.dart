import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/core/reference/app_reference_data.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

const int _kShortDescLimit = 120;

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
  bool _isLoading = true;
  String? _loadError;

  final _formKey1 = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _shortDescController;
  late final TextEditingController _fullDescController;

  Set<String> _selectedSkillIds = {};
  int _slots = 3;
  DateTime? _deadline;
  String _formatId = 'online';
  String _levelId = 'junior';
  String _categoryId = 'dev';

  bool _showSkillsError = false;
  bool _showDeadlineError = false;
  int _shortDescLength = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _shortDescController = TextEditingController();
    _fullDescController = TextEditingController();

    _titleController.addListener(_markChanged);
    _shortDescController.addListener(_markChanged);
    _fullDescController.addListener(_markChanged);
    _shortDescController.addListener(() {
      setState(() => _shortDescLength = _shortDescController.text.length);
    });

    _loadProject();
  }

  void _markChanged() => setState(() => _hasChanges = true);

  // ── Загрузка данных из Firestore ─────────────────────────────────────────
  Future<void> _loadProject() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .get();

      if (!doc.exists) {
        setState(() {
          _loadError = 'Проект не найден';
          _isLoading = false;
        });
        return;
      }

      final d = doc.data()!;

      // Заполняем контроллеры
      _titleController.text = d['title'] ?? '';
      _shortDescController.text = d['shortDescription'] ?? '';
      _fullDescController.text = d['fullDescription'] ?? '';
      _shortDescLength = _shortDescController.text.length;

      // Слоты
      _slots = d['totalSlots'] ?? 3;

      // Дедлайн — парсим строку вида "12.6.2026"
      final deadlineStr = d['deadline'] as String? ?? '';
      if (deadlineStr.isNotEmpty) {
        try {
          final parts = deadlineStr.split('.');
          if (parts.length == 3) {
            _deadline = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } catch (_) {}
      }

      // Формат — конвертируем Firestore значение → id
      final fsFormat = d['format'] as String? ?? '';
      _formatId = AppFormats.all
          .firstWhere((f) => f.firestoreValue == fsFormat,
              orElse: () => AppFormats.all.first)
          .id;

      // Уровень
      final fsLevel = d['level'] as String? ?? '';
      _levelId = AppLevels.all
          .firstWhere((l) => l.firestoreValue == fsLevel,
              orElse: () => AppLevels.all[1])
          .id;

      // Категория
      final fsCategory = d['category'] as String? ?? '';
      _categoryId = AppCategories.all
          .firstWhere((c) => c.firestoreValue == fsCategory,
              orElse: () => AppCategories.all.first)
          .id;

      // Навыки — конвертируем labels → ids
      final skillLabels =
          List<String>.from(d['requiredSkills'] ?? d['skills'] ?? []);
      _selectedSkillIds = skillLabels
          .map((label) {
            final skill = AppSkills.all
                .firstWhere((s) => s.label == label,
                    orElse: () =>
                        SkillItem(id: label, label: label, categoryId: ''));
            return skill.id;
          })
          .where((id) => id.isNotEmpty)
          .toSet();

      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });
    } catch (e) {
      setState(() {
        _loadError = 'Ошибка загрузки: $e';
        _isLoading = false;
      });
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_loadError!, style: AppTypography.body),
              const SizedBox(height: AppSizes.md),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Назад'),
              ),
            ],
          ),
        ),
      );
    }

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
              // ── Header ──
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
                              Text('Редактирование', style: AppTypography.h3),
                              if (_hasChanges)
                                Text(
                                  'Есть несохранённые изменения',
                                  style: AppTypography.caption
                                      .copyWith(color: AppColors.warning),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSizes.md, 4, AppSizes.md, AppSizes.sm),
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
                                  margin:
                                      EdgeInsets.only(right: i == 0 ? 6 : 0),
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

              // ── Form ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _step == 0
                        ? _buildStep1()
                        : _buildStep2(),
                  ),
                ),
              ),

              // ── Buttons ──
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
                        offset: const Offset(0, -3)),
                  ],
                ),
                child: _step == 0
                    ? Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _nextStep,
                              icon: const Icon(Icons.arrow_forward_rounded,
                                  size: 18),
                              label: const Text('Далее'),
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(
                                      0, AppSizes.buttonHeight)),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          SizedBox(
                            height: AppSizes.buttonHeight,
                            child: OutlinedButton.icon(
                              onPressed: _confirmDelete,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side:
                                    const BorderSide(color: AppColors.error),
                                minimumSize: const Size(
                                    0, AppSizes.buttonHeight),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.md),
                              ),
                              icon: const Icon(Icons.delete_outline_rounded,
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

  // ── Шаг 1 ────────────────────────────────────────────────────────────────

  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: Column(
        key: const ValueKey(0),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            hint: 'Название проекта',
            label: 'Название проекта *',
            controller: _titleController,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Обязательное поле';
              if (v.trim().length < 5) return 'Минимум 5 символов';
              return null;
            },
          ),
          const SizedBox(height: AppSizes.md),

          AppTextField(
            hint: 'Короткое описание (превью для карточки)',
            label: 'Краткое описание *',
            controller: _shortDescController,
            maxLines: 3,
            inputFormatters: [
              LengthLimitingTextInputFormatter(_kShortDescLimit),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Обязательное поле';
              if (v.trim().length < 10) return 'Минимум 10 символов';
              return null;
            },
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Отображается на карточке',
                  style: AppTypography.caption.copyWith(color: AppColors.grey)),
              Text(
                '$_shortDescLength/$_kShortDescLimit',
                style: AppTypography.caption.copyWith(
                  color: _shortDescLength >= _kShortDescLimit
                      ? AppColors.error
                      : AppColors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          AppTextField(
            hint: 'Подробно опиши цели, задачи и ожидаемый результат',
            label: 'Полное описание *',
            controller: _fullDescController,
            maxLines: 6,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Обязательное поле';
              if (v.trim().length < 30) return 'Минимум 30 символов';
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ── Шаг 2 ────────────────────────────────────────────────────────────────

  Widget _buildStep2() {
    final skills = AppSkills.byCategory(
        _selectedSkillIds.isNotEmpty ? _categoryId : AppCategories.all.first.id);

    return StatefulBuilder(
      key: const ValueKey(1),
      builder: (context, setLocal) {
        String activeCategoryId = _categoryId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Навыки ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Навыки (кого ищешь) *', style: AppTypography.label),
                if (_selectedSkillIds.isNotEmpty)
                  Text(
                    '${_selectedSkillIds.length} выбрано',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.primary),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.xs),

            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppCategories.all.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = AppCategories.all[i];
                  final isActive = cat.id == activeCategoryId;
                  return GestureDetector(
                    onTap: () => setLocal(() => activeCategoryId = cat.id),
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
              spacing: 6,
              runSpacing: 6,
              children: AppSkills.byCategory(activeCategoryId)
                  .map((s) => SkillChip(
                        label: s.label,
                        isSelected: _selectedSkillIds.contains(s.id),
                        onTap: () => setState(() {
                          _showSkillsError = false;
                          _hasChanges = true;
                          _selectedSkillIds.contains(s.id)
                              ? _selectedSkillIds.remove(s.id)
                              : _selectedSkillIds.add(s.id);
                        }),
                      ))
                  .toList(),
            ),

            if (_showSkillsError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Выберите хотя бы один навык',
                  style:
                      AppTypography.caption.copyWith(color: AppColors.error),
                ),
              ),
            const SizedBox(height: AppSizes.md),

            // ── Категория ──
            Text('Категория проекта *', style: AppTypography.label),
            const SizedBox(height: AppSizes.xs),
            _RefDropdown<CategoryItem>(
              value: _categoryId,
              items: AppCategories.all,
              getId: (c) => c.id,
              getLabel: (c) => c.label,
              onChanged: (v) => setState(() {
                _categoryId = v;
                _hasChanges = true;
              }),
            ),
            const SizedBox(height: AppSizes.md),

            // ── Кол-во людей ──
            Text('Кол-во людей *', style: AppTypography.label),
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
                    onPressed: () => setState(() {
                      _slots = (_slots - 1).clamp(1, 50);
                      _hasChanges = true;
                    }),
                    icon: const Icon(Icons.remove_rounded),
                    color: AppColors.primary,
                  ),
                  Expanded(
                    child: Text(
                      '$_slots ${_plural(_slots)}',
                      textAlign: TextAlign.center,
                      style: AppTypography.h3,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _slots++;
                      _hasChanges = true;
                    }),
                    icon: const Icon(Icons.add_rounded),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // ── Дедлайн ──
            Text('Дедлайн *', style: AppTypography.label),
            const SizedBox(height: AppSizes.xs),
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: _showDeadlineError
                        ? AppColors.error
                        : _deadline != null
                            ? AppColors.primary
                            : AppColors.lightGrey,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 18,
                        color: _showDeadlineError
                            ? AppColors.error
                            : _deadline != null
                                ? AppColors.primary
                                : AppColors.grey),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      _deadline != null
                          ? '${_deadline!.day}.${_deadline!.month}.${_deadline!.year}'
                          : 'Выбрать дату',
                      style: AppTypography.body.copyWith(
                        color: _showDeadlineError
                            ? AppColors.error
                            : _deadline != null
                                ? AppColors.primary
                                : AppColors.grey,
                        fontWeight: _deadline != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    if (_deadline != null) ...[
                      const Spacer(),
                      const Icon(Icons.check_circle_rounded,
                          size: 16, color: AppColors.success),
                    ],
                  ],
                ),
              ),
            ),
            if (_showDeadlineError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Выберите дедлайн',
                  style:
                      AppTypography.caption.copyWith(color: AppColors.error),
                ),
              ),
            const SizedBox(height: AppSizes.md),

            // ── Формат + Уровень ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Формат *', style: AppTypography.label),
                      const SizedBox(height: AppSizes.xs),
                      _RefDropdown<ReferenceItem>(
                        value: _formatId,
                        items: AppFormats.all,
                        getId: (f) => f.id,
                        getLabel: (f) => f.label,
                        onChanged: (v) => setState(() {
                          _formatId = v;
                          _hasChanges = true;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Уровень *', style: AppTypography.label),
                      const SizedBox(height: AppSizes.xs),
                      _RefDropdown<ReferenceItem>(
                        value: _levelId,
                        items: AppLevels.all,
                        getId: (l) => l.id,
                        getLabel: (l) => l.label,
                        onChanged: (v) => setState(() {
                          _levelId = v;
                          _hasChanges = true;
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ── Действия ─────────────────────────────────────────────────────────────

  void _nextStep() {
    final isValid = _formKey1.currentState?.validate() ?? false;
    if (isValid) setState(() => _step = 1);
  }

  Future<void> _save() async {
    final hasSkills = _selectedSkillIds.isNotEmpty;
    final hasDeadline = _deadline != null;

    setState(() {
      _showSkillsError = !hasSkills;
      _showDeadlineError = !hasDeadline;
    });

    if (!hasSkills || !hasDeadline) return;

    setState(() => _isSaving = true);

    try {
      final d = _deadline!;
      final fsFormat = AppFormats.toFirestore(_formatId) ?? _formatId;
      final fsLevel = AppLevels.toFirestore(_levelId) ?? _levelId;
      final fsCategory =
          AppCategories.toFirestore(_categoryId) ?? _categoryId;

      final skillLabels = _selectedSkillIds
          .map((id) => AppSkills.all
              .firstWhere((s) => s.id == id,
                  orElse: () =>
                      SkillItem(id: id, label: id, categoryId: ''))
              .label)
          .toList();

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .update({
        'title': _titleController.text.trim(),
        'shortDescription': _shortDescController.text.trim(),
        'fullDescription': _fullDescController.text.trim(),
        'requiredSkills': skillLabels,
        'totalSlots': _slots,
        'deadline': '${d.day}.${d.month}.${d.year}',
        'format': fsFormat,
        'level': fsLevel,
        'category': fsCategory,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Проект обновлён ✓'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        margin: const EdgeInsets.all(AppSizes.md),
      ));

      context.pop();
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ошибка сохранения: $e'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        margin: const EdgeInsets.all(AppSizes.md),
      ));
    }
  }

  Future<void> _pickDeadline() async {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? today.add(const Duration(days: 30)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
        _showDeadlineError = false;
        _hasChanges = true;
      });
    }
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
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('projects')
                  .doc(widget.projectId)
                  .delete();
              if (!mounted) return;
              context.go('/feed');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Проект удалён'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                margin: const EdgeInsets.all(AppSizes.md),
              ));
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
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
            child:
                Text('Выйти', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _plural(int n) {
    if (n == 1) return 'человек';
    if (n >= 2 && n <= 4) return 'человека';
    return 'человек';
  }
}

// ─── Универсальный дропдаун ───────────────────────────────────────────────

class _RefDropdown<T> extends StatelessWidget {
  final String value;
  final List<T> items;
  final String Function(T) getId;
  final String Function(T) getLabel;
  final void Function(String) onChanged;

  const _RefDropdown({
    required this.value,
    required this.items,
    required this.getId,
    required this.getLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
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
          .map((item) => DropdownMenuItem(
                value: getId(item),
                child: Text(getLabel(item), style: AppTypography.body),
              ))
          .toList(),
      onChanged: (v) => onChanged(v!),
    );
  }
}