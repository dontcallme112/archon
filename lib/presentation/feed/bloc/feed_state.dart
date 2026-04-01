part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, loaded, error }

class FeedState {
  final FeedStatus status;
  final List<ProjectEntity> projects;
  final Set<String> favoriteIds;
  final String activeCategory;
  final String activeFormat;
  final String searchQuery;
  final String? errorMessage;

  const FeedState({
    this.status = FeedStatus.initial,
    this.projects = const [],
    this.favoriteIds = const {},
    this.activeCategory = 'Все',
    this.activeFormat = 'Все',
    this.searchQuery = '',
    this.errorMessage,
  });

  FeedState copyWith({
    FeedStatus? status,
    List<ProjectEntity>? projects,
    Set<String>? favoriteIds,
    String? activeCategory,
    String? activeFormat,
    String? searchQuery,
    String? errorMessage,
  }) =>
      FeedState(
        status: status ?? this.status,
        projects: projects ?? this.projects,
        favoriteIds: favoriteIds ?? this.favoriteIds,
        activeCategory: activeCategory ?? this.activeCategory,
        activeFormat: activeFormat ?? this.activeFormat,
        searchQuery: searchQuery ?? this.searchQuery,
        errorMessage: errorMessage,
      );

  bool isFavorite(String projectId) => favoriteIds.contains(projectId);
}
