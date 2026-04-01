import 'package:flutter/material.dart';
import 'package:student_app/presentation/common/widgets/project_card.dart';
import '../../common/widgets/common_widgets.dart';
import '../../../domain/entities/entities.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final Set<String> _selectedSkills = {};
  String _format = 'Все';
  String _level = 'Все';
  RangeValues _slotsRange = const RangeValues(1, 10);
  DateTime? _deadline;
  bool _isSearching = false;
  bool _searched = false;
  bool _showFilters = false;
  List<ProjectEntity> _results = [];

  final _availableSkills = [
    'Figma', 'UI/UX', 'Flutter', 'React',
    'Node.js', 'Python', 'Marketing', 'SMM',
    'iOS', 'Android', 'ML/AI', 'DevOps',
  ];
  final _formats = ['Все', 'Онлайн', 'Оффлайн'];
  final _levels = ['Все', 'Junior', 'Middle', 'Senior'];

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedSkills.isNotEmpty) count++;
    if (_format != 'Все') count++;
    if (_level != 'Все') count++;
    if (_deadline != null) count++;
    if (_slotsRange != const RangeValues(1, 10)) count++;
    return count;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Search bar ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      style: AppTypography.body,
                      onFieldSubmitted: (_) => _search(),
                      decoration: InputDecoration(
                        hintText: 'Поиск по навыкам, названию...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.grey, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() { _results = []; _searched = false; });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  // Filter button with badge
                  GestureDetector(
                    onTap: () => setState(() => _showFilters = !_showFilters),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _showFilters ? AppColors.primary : AppColors.white,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: _showFilters ? AppColors.white : AppColors.dark,
                            size: 20,
                          ),
                        ),
                        if (_activeFiltersCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$_activeFiltersCount',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Collapsible filters ──────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _showFilters
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, 0),
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.dark.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Фильтры', style: AppTypography.h4),
                              TextButton(
                                onPressed: _resetFilters,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text('Сбросить',
                                    style: AppTypography.label.copyWith(color: AppColors.error)),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text('Навыки', style: AppTypography.label),
                          const SizedBox(height: AppSizes.xs),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _availableSkills
                                .map((s) => SkillChip(
                                      label: s,
                                      isSelected: _selectedSkills.contains(s),
                                      onTap: () => setState(() {
                                        _selectedSkills.contains(s)
                                            ? _selectedSkills.remove(s)
                                            : _selectedSkills.add(s);
                                      }),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: AppSizes.md),
                          // Deadline
                          Text('Дедлайн', style: AppTypography.label),
                          const SizedBox(height: AppSizes.xs),
                          GestureDetector(
                            onTap: _pickDeadline,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.grey),
                                  const SizedBox(width: AppSizes.sm),
                                  Text(
                                    _deadline != null
                                        ? '${_deadline!.day}.${_deadline!.month}.${_deadline!.year}'
                                        : 'Выбрать дату',
                                    style: AppTypography.body.copyWith(
                                      color: _deadline != null ? AppColors.dark : AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.md),
                          // Format + Level
                          Row(
                            children: [
                              Expanded(child: _buildDropdown('Формат', _format, _formats,
                                  (v) => setState(() => _format = v))),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(child: _buildDropdown('Уровень', _level, _levels,
                                  (v) => setState(() => _level = v))),
                            ],
                          ),
                          const SizedBox(height: AppSizes.md),
                          // Slots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Кол-во людей', style: AppTypography.label),
                              Text(
                                '${_slotsRange.start.round()}–${_slotsRange.end.round()}',
                                style: AppTypography.caption.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                          RangeSlider(
                            values: _slotsRange,
                            min: 1,
                            max: 20,
                            divisions: 19,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.lightGrey,
                            onChanged: (v) => setState(() => _slotsRange = v),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // ─── Active chips row ─────────────────────────────────
            if (_selectedSkills.isNotEmpty || _format != 'Все' || _level != 'Все')
              SizedBox(
                height: 40,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 4),
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._selectedSkills.map((s) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: SkillChip(
                            label: s,
                            isSelected: true,
                            canDelete: true,
                            onDelete: () => setState(() => _selectedSkills.remove(s)),
                          ),
                        )),
                    if (_format != 'Все')
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: SkillChip(
                          label: _format,
                          isSelected: true,
                          canDelete: true,
                          onDelete: () => setState(() => _format = 'Все'),
                        ),
                      ),
                    if (_level != 'Все')
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: SkillChip(
                          label: _level,
                          isSelected: true,
                          canDelete: true,
                          onDelete: () => setState(() => _level = 'Все'),
                        ),
                      ),
                  ],
                ),
              ),

            // ─── Search button ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
              child: PrimaryButton(
                label: 'Найти проекты',
                icon: Icons.search_rounded,
                isLoading: _isSearching,
                onTap: _search,
              ),
            ),

            // ─── Results ─────────────────────────────────────────
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, void Function(String) onChanged) {
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: AppTypography.body))).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (!_searched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: AppSizes.md),
            Text('Найди свой проект', style: AppTypography.h3),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Введи название или выбери\nнавыки и нажми «Найти»',
              style: AppTypography.body.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: AppColors.lightGrey),
            const SizedBox(height: AppSizes.md),
            Text('Ничего не найдено', style: AppTypography.h3.copyWith(color: AppColors.grey)),
            const SizedBox(height: AppSizes.xs),
            Text('Попробуй изменить фильтры', style: AppTypography.body.copyWith(color: AppColors.grey)),
            const SizedBox(height: AppSizes.md),
            OutlinedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('Изменить фильтры'),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(
            'Найдено: ${_results.length} проектов',
            style: AppTypography.caption.copyWith(color: AppColors.grey),
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            itemCount: _results.length,
            itemBuilder: (context, i) => ProjectCard(
              project: _results[i],
              isFavorite: false,
              onFavorite: () {},
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _search() async {
    setState(() { _isSearching = true; _showFilters = false; });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _isSearching = false;
      _searched = true;
      _results = _mockResults();
    });
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _resetFilters() => setState(() {
        _selectedSkills.clear();
        _format = 'Все';
        _level = 'Все';
        _slotsRange = const RangeValues(1, 10);
        _deadline = null;
      });

  List<ProjectEntity> _mockResults() {
    final author = const UserEntity(id: 'u1', name: 'Иван Иванов', skills: [], level: 'middle');
    return [
      ProjectEntity(
        id: 'p1',
        title: 'Redesign приложения для фитнеса',
        shortDescription: 'Создаём интуитивный UX для трекера тренировок.',
        fullDescription: '',
        requiredSkills: ['UI/UX', 'Figma', 'Prototyping'],
        deadline: '15 мая 2025',
        format: 'Онлайн',
        level: 'middle',
        totalSlots: 5,
        filledSlots: 3,
        author: author,
        teamMembers: [author],
        category: 'Дизайн',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ProjectEntity(
        id: 'p2',
        title: 'AI Стартап для студентов',
        shortDescription: 'Разрабатываем AI-инструмент для автоматизации учёбы.',
        fullDescription: '',
        requiredSkills: ['Python', 'ML/AI', 'React'],
        deadline: '1 июня 2025',
        format: 'Онлайн',
        level: 'junior',
        totalSlots: 6,
        filledSlots: 2,
        author: author,
        teamMembers: [],
        category: 'Разработка',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];
  }
}