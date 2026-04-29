// ============================================================
//  ProjectHub — Справочник данных (Reference Data)
//  lib/core/reference/app_reference_data.dart
// ============================================================

// ── УРОВНИ ──────────────────────────────────────────────────

class AppLevels {
  AppLevels._();

  static const List<ReferenceItem> all = [
    ReferenceItem(id: 'intern', label: 'Стажёр',  firestoreValue: 'intern',  order: 0),
    ReferenceItem(id: 'junior', label: 'Junior',  firestoreValue: 'junior',  order: 1),
    ReferenceItem(id: 'middle', label: 'Middle',  firestoreValue: 'middle',  order: 2),
    ReferenceItem(id: 'senior', label: 'Senior',  firestoreValue: 'senior',  order: 3),
  ];

  static String? toFirestore(String? id) =>
      id == null ? null : all.firstWhere((e) => e.id == id, orElse: () => all.first).firestoreValue;
}

// ── ФОРМАТЫ ─────────────────────────────────────────────────

class AppFormats {
  AppFormats._();

  static const List<ReferenceItem> all = [
    ReferenceItem(id: 'online',  label: 'Онлайн', firestoreValue: 'Онлайн',  order: 0),
    ReferenceItem(id: 'offline', label: 'Офлайн', firestoreValue: 'Оффлайн', order: 1),
    ReferenceItem(id: 'hybrid',  label: 'Гибрид', firestoreValue: 'Гибрид',  order: 2),
  ];

  static String? toFirestore(String? id) =>
      id == null ? null : all.firstWhere((e) => e.id == id, orElse: () => all.first).firestoreValue;
}

// ── КАТЕГОРИИ ───────────────────────────────────────────────

class AppCategories {
  AppCategories._();

  static const List<CategoryItem> all = [
    CategoryItem(id: 'dev',        label: 'Разработка',         firestoreValue: 'Разработка',         icon: 'code',            order: 0),
    CategoryItem(id: 'design',     label: 'Дизайн',             firestoreValue: 'Дизайн',             icon: 'palette',         order: 1),
    CategoryItem(id: 'marketing',  label: 'Маркетинг',          firestoreValue: 'Маркетинг',          icon: 'trending_up',     order: 2),
    CategoryItem(id: 'data',       label: 'Аналитика и данные', firestoreValue: 'Аналитика',          icon: 'bar_chart',       order: 3),
    CategoryItem(id: 'management', label: 'Менеджмент',         firestoreValue: 'Менеджмент',         icon: 'groups',          order: 4),
    CategoryItem(id: 'finance',    label: 'Финансы',            firestoreValue: 'Финансы',            icon: 'account_balance', order: 5),
    CategoryItem(id: 'hr',         label: 'HR / Рекрутинг',     firestoreValue: 'HR',                 icon: 'person_search',   order: 6),
    CategoryItem(id: 'content',    label: 'Контент и медиа',    firestoreValue: 'Контент',            icon: 'video_library',   order: 7),
    CategoryItem(id: 'legal',      label: 'Юриспруденция',      firestoreValue: 'Юриспруденция',      icon: 'gavel',           order: 8),
    CategoryItem(id: 'other',      label: 'Другое',             firestoreValue: 'Другое',             icon: 'more_horiz',      order: 9),
  ];

  static String? toFirestore(String? id) =>
      id == null ? null : all.firstWhere((e) => e.id == id, orElse: () => all.first).firestoreValue;
}

// ── НАВЫКИ ──────────────────────────────────────────────────

class AppSkills {
  AppSkills._();

  static const List<SkillItem> development = [
    SkillItem(id: 'flutter',     label: 'Flutter',      categoryId: 'dev'),
    SkillItem(id: 'dart',        label: 'Dart',         categoryId: 'dev'),
    SkillItem(id: 'react',       label: 'React',        categoryId: 'dev'),
    SkillItem(id: 'react_native',label: 'React Native', categoryId: 'dev'),
    SkillItem(id: 'vue',         label: 'Vue.js',       categoryId: 'dev'),
    SkillItem(id: 'nextjs',      label: 'Next.js',      categoryId: 'dev'),
    SkillItem(id: 'nodejs',      label: 'Node.js',      categoryId: 'dev'),
    SkillItem(id: 'python',      label: 'Python',       categoryId: 'dev'),
    SkillItem(id: 'java',        label: 'Java',         categoryId: 'dev'),
    SkillItem(id: 'kotlin',      label: 'Kotlin',       categoryId: 'dev'),
    SkillItem(id: 'swift',       label: 'Swift',        categoryId: 'dev'),
    SkillItem(id: 'csharp',      label: 'C#',           categoryId: 'dev'),
    SkillItem(id: 'typescript',  label: 'TypeScript',   categoryId: 'dev'),
    SkillItem(id: 'go',          label: 'Go',           categoryId: 'dev'),
    SkillItem(id: 'rust',        label: 'Rust',         categoryId: 'dev'),
    SkillItem(id: 'firebase',    label: 'Firebase',     categoryId: 'dev'),
    SkillItem(id: 'supabase',    label: 'Supabase',     categoryId: 'dev'),
    SkillItem(id: 'postgresql',  label: 'PostgreSQL',   categoryId: 'dev'),
    SkillItem(id: 'mongodb',     label: 'MongoDB',      categoryId: 'dev'),
    SkillItem(id: 'docker',      label: 'Docker',       categoryId: 'dev'),
    SkillItem(id: 'git',         label: 'Git',          categoryId: 'dev'),
    SkillItem(id: 'graphql',     label: 'GraphQL',      categoryId: 'dev'),
    SkillItem(id: 'rest_api',    label: 'REST API',     categoryId: 'dev'),
    SkillItem(id: 'html_css',    label: 'HTML / CSS',   categoryId: 'dev'),
  ];

  static const List<SkillItem> design = [
    SkillItem(id: 'figma',       label: 'Figma',            categoryId: 'design'),
    SkillItem(id: 'adobe_xd',    label: 'Adobe XD',         categoryId: 'design'),
    SkillItem(id: 'illustrator', label: 'Illustrator',      categoryId: 'design'),
    SkillItem(id: 'photoshop',   label: 'Photoshop',        categoryId: 'design'),
    SkillItem(id: 'ux_research', label: 'UX Research',      categoryId: 'design'),
    SkillItem(id: 'ui_design',   label: 'UI Design',        categoryId: 'design'),
    SkillItem(id: 'motion',      label: 'Motion Design',    categoryId: 'design'),
    SkillItem(id: 'branding',    label: 'Брендинг',         categoryId: 'design'),
    SkillItem(id: 'prototyping', label: 'Прототипирование', categoryId: 'design'),
  ];

  static const List<SkillItem> marketing = [
    SkillItem(id: 'smm',          label: 'SMM',              categoryId: 'marketing'),
    SkillItem(id: 'seo',          label: 'SEO',              categoryId: 'marketing'),
    SkillItem(id: 'google_ads',   label: 'Google Ads',       categoryId: 'marketing'),
    SkillItem(id: 'meta_ads',     label: 'Meta Ads',         categoryId: 'marketing'),
    SkillItem(id: 'email_mktg',   label: 'Email-маркетинг',  categoryId: 'marketing'),
    SkillItem(id: 'content_mktg', label: 'Контент-маркетинг',categoryId: 'marketing'),
    SkillItem(id: 'copywriting',  label: 'Копирайтинг',      categoryId: 'marketing'),
    SkillItem(id: 'analytics_mktg',label: 'Веб-аналитика',   categoryId: 'marketing'),
    SkillItem(id: 'pr',           label: 'PR',               categoryId: 'marketing'),
  ];

  static const List<SkillItem> data = [
    SkillItem(id: 'excel',       label: 'Excel / Sheets',  categoryId: 'data'),
    SkillItem(id: 'sql',         label: 'SQL',             categoryId: 'data'),
    SkillItem(id: 'tableau',     label: 'Tableau',         categoryId: 'data'),
    SkillItem(id: 'power_bi',    label: 'Power BI',        categoryId: 'data'),
    SkillItem(id: 'ml',          label: 'Machine Learning',categoryId: 'data'),
    SkillItem(id: 'data_science',label: 'Data Science',    categoryId: 'data'),
    SkillItem(id: 'pandas',      label: 'Pandas',          categoryId: 'data'),
    SkillItem(id: 'statistics',  label: 'Статистика',      categoryId: 'data'),
  ];

  static const List<SkillItem> management = [
    SkillItem(id: 'agile',      label: 'Agile / Scrum',    categoryId: 'management'),
    SkillItem(id: 'jira',       label: 'Jira',             categoryId: 'management'),
    SkillItem(id: 'notion',     label: 'Notion',           categoryId: 'management'),
    SkillItem(id: 'product_mgt',label: 'Product Management',categoryId: 'management'),
    SkillItem(id: 'project_mgt',label: 'Project Management',categoryId: 'management'),
    SkillItem(id: 'presentation',label: 'Презентации',     categoryId: 'management'),
  ];

  static const List<SkillItem> finance = [
    SkillItem(id: 'accounting',         label: 'Бухгалтерия',   categoryId: 'finance'),
    SkillItem(id: '1c',                 label: '1C',            categoryId: 'finance'),
    SkillItem(id: 'financial_analysis', label: 'Фин. анализ',   categoryId: 'finance'),
    SkillItem(id: 'budgeting',          label: 'Бюджетирование',categoryId: 'finance'),
  ];

  static const List<SkillItem> hr = [
    SkillItem(id: 'recruiting', label: 'Рекрутинг', categoryId: 'hr'),
    SkillItem(id: 'onboarding', label: 'Онбординг', categoryId: 'hr'),
    SkillItem(id: 'hr_brand',   label: 'HR-бренд',  categoryId: 'hr'),
  ];

  static const List<SkillItem> content = [
    SkillItem(id: 'video_edit',  label: 'Монтаж видео', categoryId: 'content'),
    SkillItem(id: 'photography', label: 'Фотография',   categoryId: 'content'),
    SkillItem(id: 'blogging',    label: 'Блогинг',      categoryId: 'content'),
    SkillItem(id: 'podcast',     label: 'Подкасты',     categoryId: 'content'),
  ];

  static List<SkillItem> get all => [
        ...development, ...design, ...marketing,
        ...data, ...management, ...finance, ...hr, ...content,
      ];

  static List<SkillItem> byCategory(String categoryId) =>
      all.where((s) => s.categoryId == categoryId).toList();
}

// ── МОДЕЛИ ──────────────────────────────────────────────────

class ReferenceItem {
  final String id;
  final String label;
  final String firestoreValue; // значение которое хранится в Firestore
  final int order;

  const ReferenceItem({
    required this.id,
    required this.label,
    required this.firestoreValue,
    required this.order,
  });
}

class CategoryItem extends ReferenceItem {
  final String icon;

  const CategoryItem({
    required super.id,
    required super.label,
    required super.firestoreValue,
    required this.icon,
    required super.order,
  });
}

class SkillItem {
  final String id;
  final String label;
  final String categoryId;

  const SkillItem({
    required this.id,
    required this.label,
    required this.categoryId,
  });
}