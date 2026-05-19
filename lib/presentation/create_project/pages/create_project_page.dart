import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/core/reference/app_reference_data.dart';
import '../bloc/create_project_bloc.dart';
import '../../../domain/usecases/project/project_usecases.dart';
import '../../../domain/repositories/firestore_project_repository.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

const int _kShortDescLimit = 50;
const int _kSkillLimitPerCategory = 5;
const int _kFullDescLimit = 1000;

class CreateProjectPage extends StatelessWidget {
  const CreateProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateProjectBloc(
        createProject: CreateProjectUseCase(FirestoreProjectRepository()),
      ),
      child: const _CreateProjectView(),
    );
  }
}

class _CreateProjectView extends StatefulWidget {
  const _CreateProjectView();

  @override
  State<_CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<_CreateProjectView> {
  int _step = 0;
  bool _autosaved = false;

  final _formKey1 = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _fullDescController = TextEditingController();

  final Set<String> _selectedSkillIds = {};
  int _slots = 3;
  DateTime? _deadline;
  String _formatId = 'online';
  String _levelId = 'junior';
  String _categoryId = 'dev';

  bool _showSkillsError = false;
  bool _showDeadlineError = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onChanged);
    _shortDescController.addListener(_onChanged);
    _fullDescController.addListener(_onChanged);
  }

  void _onChanged() {
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
    return BlocListener<CreateProjectBloc, CreateProjectState>(
      listener: (context, state) {
        if (state.status == CreateProjectStatus.success) {
          _showSuccess(context);
        } else if (state.status == CreateProjectStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Ошибка публикации'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              margin: const EdgeInsets.all(AppSizes.md),
            ),
          );
        }
      },
      child: BlocBuilder<CreateProjectBloc, CreateProjectState>(
        builder: (context, state) {
          final isLoading = state.status == CreateProjectStatus.loading;
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  // ── Header ──
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 20,
                          ),
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
                              const Icon(
                                Icons.cloud_done_rounded,
                                size: 14,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Автосохранение',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // ── Step indicator ──
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.md,
                      0,
                      AppSizes.md,
                      AppSizes.md,
                    ),
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
                                    AppSizes.radiusFull,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
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
                            ? _Step1(
                                key: const ValueKey(0),
                                formKey: _formKey1,
                                titleController: _titleController,
                                shortDescController: _shortDescController,
                                fullDescController: _fullDescController,
                              )
                            : _Step2(
                                key: const ValueKey(1),
                                selectedSkillIds: _selectedSkillIds,
                                slots: _slots,
                                formatId: _formatId,
                                levelId: _levelId,
                                categoryId: _categoryId,
                                deadline: _deadline,
                                showSkillsError: _showSkillsError,
                                showDeadlineError: _showDeadlineError,
                                onSkillToggle: (id) => setState(() {
                                  _showSkillsError = false;
                                  if (_selectedSkillIds.contains(id)) {
                                    _selectedSkillIds.remove(id);
                                  } else {
                                    // Проверка лимита по категории
                                    final cat = AppSkills.all
                                        .firstWhere(
                                          (s) => s.id == id,
                                          orElse: () => SkillItem(
                                            id: '',
                                            label: '',
                                            categoryId: '',
                                          ),
                                        )
                                        .categoryId;
                                    final count = _selectedSkillIds.where((
                                      sid,
                                    ) {
                                      return AppSkills.all
                                              .firstWhere(
                                                (s) => s.id == sid,
                                                orElse: () => SkillItem(
                                                  id: '',
                                                  label: '',
                                                  categoryId: '',
                                                ),
                                              )
                                              .categoryId ==
                                          cat;
                                    }).length;
                                    if (count < _kSkillLimitPerCategory) {
                                      _selectedSkillIds.add(id);
                                    }
                                  }
                                }),
                                onSlotsDecrement: () => setState(
                                  () => _slots = (_slots - 1).clamp(1, 50),
                                ),
                                onSlotsIncrement: () => setState(
                                  () => _slots = (_slots + 1).clamp(1, 50),
                                ),
                                onFormatChanged: (v) =>
                                    setState(() => _formatId = v),
                                onLevelChanged: (v) =>
                                    setState(() => _levelId = v),
                                onCategoryChanged: (v) =>
                                    setState(() => _categoryId = v),
                                onDeadlineTap: _pickDeadline,
                              ),
                      ),
                    ),
                  ),

                  // ── Button ──
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
                      label: _step == 0 ? 'Далее' : 'Опубликовать проект',
                      icon: _step == 0
                          ? Icons.arrow_forward_rounded
                          : Icons.rocket_launch_rounded,
                      isLoading: isLoading,
                      onTap: _step == 0 ? _nextStep : () => _publish(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _nextStep() {
    final isValid = _formKey1.currentState?.validate() ?? false;
    if (isValid) setState(() => _step = 1);
  }

  void _publish(BuildContext context) {
    final hasSkills = _selectedSkillIds.isNotEmpty;
    final hasDeadline = _deadline != null;

    setState(() {
      _showSkillsError = !hasSkills;
      _showDeadlineError = !hasDeadline;
    });

    if (!hasSkills || !hasDeadline) return;

    final d = _deadline!;
    final fsFormat = AppFormats.toFirestore(_formatId) ?? _formatId;
    final fsLevel = AppLevels.toFirestore(_levelId) ?? _levelId;
    final fsCategory = AppCategories.toFirestore(_categoryId) ?? _categoryId;

    final skillLabels = _selectedSkillIds
        .map(
          (id) => AppSkills.all
              .firstWhere(
                (s) => s.id == id,
                orElse: () => SkillItem(id: id, label: id, categoryId: ''),
              )
              .label,
        )
        .toList();

    context.read<CreateProjectBloc>().add(
      CreateProjectPublished(
        title: _titleController.text.trim(),
        shortDescription: _shortDescController.text.trim(),
        fullDescription: _fullDescController.text.trim(),
        skills: skillLabels,
        slots: _slots,
        deadline: '${d.day}.${d.month}.${d.year}',
        format: fsFormat,
        level: fsLevel,
        category: fsCategory,
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: today.add(const Duration(days: 30)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
        _showDeadlineError = false;
      });
    }
  }

  void _showSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                color: AppColors.success,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Проект опубликован! 🚀',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
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

class _Step1 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController shortDescController;
  final TextEditingController fullDescController;

  const _Step1({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.shortDescController,
    required this.fullDescController,
  });

  @override
  State<_Step1> createState() => _Step1State();
}

class _Step1State extends State<_Step1> {
  int _shortDescLength = 0;
  int _fullDescLength = 0;
  @override
  void initState() {
    super.initState();
    _shortDescLength = widget.shortDescController.text.length;
    widget.shortDescController.addListener(_onShortDescChanged);
    _fullDescLength = widget.fullDescController.text.length;
    widget.fullDescController.addListener(_onFullDescChanged);
  }

  void _onShortDescChanged() =>
      setState(() => _shortDescLength = widget.shortDescController.text.length);
  void _onFullDescChanged() =>
      setState(() => _fullDescLength = widget.fullDescController.text.length);
  @override
  void dispose() {
    widget.shortDescController.removeListener(_onShortDescChanged);
    widget.fullDescController.removeListener(_onFullDescChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            hint: 'Название проекта',
            label: 'Название проекта *',
            controller: widget.titleController,
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
            controller: widget.shortDescController,
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
              Text(
                'Отображается на карточке проекта',
                style: AppTypography.caption.copyWith(color: AppColors.grey),
              ),
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
            controller: widget.fullDescController,
            maxLines: 6,
            inputFormatters: [
              LengthLimitingTextInputFormatter(_kFullDescLimit),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Обязательное поле';
              if (v.trim().length < 30) return 'Минимум 30 символов';
              return null;
            },
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Максимум $_kFullDescLimit символов',
                style: AppTypography.caption.copyWith(color: AppColors.grey),
              ),
              Text(
                '$_fullDescLength/$_kFullDescLimit',
                style: AppTypography.caption.copyWith(
                  color: _fullDescLength >= _kFullDescLimit
                      ? AppColors.error
                      : AppColors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          Container(
            padding: const EdgeInsets.all(AppSizes.sm + 4),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'Хорошее описание повышает шансы найти команду. Расскажи о целях и стеке.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2 ───────────────────────────────────────────────────────────────

class _Step2 extends StatefulWidget {
  final Set<String> selectedSkillIds;
  final int slots;
  final String formatId;
  final String levelId;
  final String categoryId;
  final DateTime? deadline;
  final bool showSkillsError;
  final bool showDeadlineError;
  final void Function(String) onSkillToggle;
  final VoidCallback onSlotsDecrement;
  final VoidCallback onSlotsIncrement;
  final void Function(String) onFormatChanged;
  final void Function(String) onLevelChanged;
  final void Function(String) onCategoryChanged;
  final VoidCallback onDeadlineTap;

  const _Step2({
    super.key,
    required this.selectedSkillIds,
    required this.slots,
    required this.formatId,
    required this.levelId,
    required this.categoryId,
    required this.deadline,
    required this.showSkillsError,
    required this.showDeadlineError,
    required this.onSkillToggle,
    required this.onSlotsDecrement,
    required this.onSlotsIncrement,
    required this.onFormatChanged,
    required this.onLevelChanged,
    required this.onCategoryChanged,
    required this.onDeadlineTap,
  });

  @override
  State<_Step2> createState() => _Step2State();
}

class _Step2State extends State<_Step2> {
  late String _activeCategoryId;

  @override
  void initState() {
    super.initState();
    _activeCategoryId = AppCategories.all.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final skills = AppSkills.byCategory(_activeCategoryId);

    // Считаем выбрано навыков в текущей категории
    final selectedInCategory = skills
        .where((s) => widget.selectedSkillIds.contains(s.id))
        .length;
    final limitReached = selectedInCategory >= _kSkillLimitPerCategory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Навыки ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Навыки (кого ищешь) *', style: AppTypography.label),
            if (widget.selectedSkillIds.isNotEmpty)
              Text(
                '${widget.selectedSkillIds.length} выбрано',
                style: AppTypography.caption.copyWith(color: AppColors.primary),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'До 5 навыков в каждой категории',
          style: AppTypography.caption.copyWith(color: AppColors.grey),
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
                onTap: () => setState(() => _activeCategoryId = cat.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
        const SizedBox(height: AppSizes.sm),

        if (limitReached)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Лимит 5 навыков в этой категории достигнут',
              style: AppTypography.caption.copyWith(color: AppColors.error),
            ),
          ),

        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: skills.map((s) {
            final isSelected = widget.selectedSkillIds.contains(s.id);
            final isDisabled = limitReached && !isSelected;
            return SkillChip(
              label: s.label,
              isSelected: isSelected,
              onTap: isDisabled ? null : () => widget.onSkillToggle(s.id),
            );
          }).toList(),
        ),

        if (widget.showSkillsError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Выберите хотя бы один навык',
              style: AppTypography.caption.copyWith(color: AppColors.error),
            ),
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
                onPressed: widget.onSlotsDecrement,
                icon: const Icon(Icons.remove_rounded),
                color: AppColors.primary,
              ),
              Expanded(
                child: Text(
                  '${widget.slots} ${_plural(widget.slots)}',
                  textAlign: TextAlign.center,
                  style: AppTypography.h3,
                ),
              ),
              IconButton(
                onPressed: widget.slots >= 50 ? null : widget.onSlotsIncrement,
                icon: const Icon(Icons.add_rounded),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Максимум 50 человек',
          style: AppTypography.caption.copyWith(color: AppColors.grey),
        ),

        const SizedBox(height: AppSizes.md),

        // ── Дедлайн ──
        Text('Дедлайн *', style: AppTypography.label),
        const SizedBox(height: AppSizes.xs),
        GestureDetector(
          onTap: widget.onDeadlineTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: widget.showDeadlineError
                    ? AppColors.error
                    : widget.deadline != null
                    ? AppColors.primary
                    : AppColors.lightGrey,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: widget.showDeadlineError
                      ? AppColors.error
                      : widget.deadline != null
                      ? AppColors.primary
                      : AppColors.grey,
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  widget.deadline != null
                      ? '${widget.deadline!.day}.${widget.deadline!.month}.${widget.deadline!.year}'
                      : 'Выбрать дату',
                  style: AppTypography.body.copyWith(
                    color: widget.showDeadlineError
                        ? AppColors.error
                        : widget.deadline != null
                        ? AppColors.primary
                        : AppColors.grey,
                    fontWeight: widget.deadline != null
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (widget.deadline != null) ...[
                  const Spacer(),
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.success,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (widget.showDeadlineError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Выберите дедлайн',
              style: AppTypography.caption.copyWith(color: AppColors.error),
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
                  _ReferenceDropdown<ReferenceItem>(
                    value: widget.formatId,
                    items: AppFormats.all,
                    getId: (f) => f.id,
                    getLabel: (f) => f.label,
                    onChanged: widget.onFormatChanged,
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
                  _ReferenceDropdown<ReferenceItem>(
                    value: widget.levelId,
                    items: AppLevels.all,
                    getId: (l) => l.id,
                    getLabel: (l) => l.label,
                    onChanged: widget.onLevelChanged,
                  ),
                ],
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

class _ReferenceDropdown<T> extends StatelessWidget {
  final String value;
  final List<T> items;
  final String Function(T) getId;
  final String Function(T) getLabel;
  final void Function(String) onChanged;

  const _ReferenceDropdown({
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: getId(item),
              child: Text(getLabel(item), style: AppTypography.body),
            ),
          )
          .toList(),
      onChanged: (v) => onChanged(v!),
    );
  }
}
