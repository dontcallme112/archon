part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, loaded, loadingMore, error }

class FeedState {
  final FeedStatus status;
  final List<ProjectEntity> projects;
  final Set<String> activeSkills; // множественный выбор навыков
  final String? activeFormat;
  final String? activeLevel;
  final String searchQuery;
  final String? errorMessage;
  final bool hasMore;

  const FeedState({
    this.status = FeedStatus.initial,
    this.projects = const [],
    this.activeSkills = const {},
    this.activeFormat,
    this.activeLevel,
    this.searchQuery = '',
    this.errorMessage,
    this.hasMore = true,
  });

  bool get hasActiveFilters =>
      activeSkills.isNotEmpty || activeFormat != null || activeLevel != null;

  FeedState copyWith({
    FeedStatus? status,
    List<ProjectEntity>? projects,
    Set<String>? activeSkills,
    String? activeFormat,
    String? activeLevel,
    String? searchQuery,
    String? errorMessage,
    bool? hasMore,
    bool clearSkills = false,
    bool clearFormat = false,
    bool clearLevel = false,
  }) => FeedState(
    status: status ?? this.status,
    projects: projects ?? this.projects,
    activeSkills: clearSkills ? {} : activeSkills ?? this.activeSkills,
    activeFormat: clearFormat ? null : activeFormat ?? this.activeFormat,
    activeLevel: clearLevel ? null : activeLevel ?? this.activeLevel,
    searchQuery: searchQuery ?? this.searchQuery,
    errorMessage: errorMessage,
    hasMore: hasMore ?? this.hasMore,
  );
}
