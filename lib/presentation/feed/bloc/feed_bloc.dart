import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_app/core/utils/result.dart';
import 'package:student_app/domain/usecases/project/project_usecases.dart';
import '../../../domain/entities/entities.dart';

part 'feed_event.dart';
part 'feed_state.dart';

const int _kPageSize = 10;

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedProjectsUseCase _getFeedProjects;
  Timer? _searchDebounce;

  FeedBloc({
    required GetFeedProjectsUseCase getFeedProjects,
  })  : _getFeedProjects = getFeedProjects,
        super(const FeedState()) {
    on<FeedLoadRequested>(_onLoad);
    on<FeedRefreshRequested>(_onRefresh);
    on<FeedLoadMoreRequested>(_onLoadMore);
    on<FeedCategoryChanged>(_onCategoryChanged);
    on<FeedFormatChanged>(_onFormatChanged);
    on<FeedLevelChanged>(_onLevelChanged);
    on<FeedSearchChanged>(_onSearchChanged);
    on<FeedFiltersCleared>(_onFiltersCleared);
  }

  Future<void> _onLoad(FeedLoadRequested event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.loading));
    await _loadProjects(emit, reset: true);
  }

  Future<void> _onRefresh(
      FeedRefreshRequested event, Emitter<FeedState> emit) async {
    await _loadProjects(emit, reset: true);
  }

  Future<void> _onLoadMore(
      FeedLoadMoreRequested event, Emitter<FeedState> emit) async {
    if (!state.hasMore || state.status == FeedStatus.loadingMore) return;
    emit(state.copyWith(status: FeedStatus.loadingMore));
    await _loadProjects(emit, reset: false);
  }

  Future<void> _onCategoryChanged(
      FeedCategoryChanged event, Emitter<FeedState> emit) async {
    emit(state.copyWith(
      activeCategory: event.category,
      clearCategory: event.category == null,
      status: FeedStatus.loading,
    ));
    await _loadProjects(emit, reset: true);
  }

  Future<void> _onFormatChanged(
      FeedFormatChanged event, Emitter<FeedState> emit) async {
    emit(state.copyWith(
      activeFormat: event.format,
      clearFormat: event.format == null,
      status: FeedStatus.loading,
    ));
    await _loadProjects(emit, reset: true);
  }

  Future<void> _onLevelChanged(
      FeedLevelChanged event, Emitter<FeedState> emit) async {
    emit(state.copyWith(
      activeLevel: event.level,
      clearLevel: event.level == null,
      status: FeedStatus.loading,
    ));
    await _loadProjects(emit, reset: true);
  }

  Future<void> _onSearchChanged(
      FeedSearchChanged event, Emitter<FeedState> emit) async {
    emit(state.copyWith(searchQuery: event.query));
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      add(FeedRefreshRequested());
    });
  }

  Future<void> _onFiltersCleared(
      FeedFiltersCleared event, Emitter<FeedState> emit) async {
    emit(state.copyWith(
      clearCategory: true,
      clearFormat: true,
      clearLevel: true,
      searchQuery: '',
      status: FeedStatus.loading,
    ));
    await _loadProjects(emit, reset: true);
  }

  Future<void> _loadProjects(Emitter<FeedState> emit,
      {required bool reset}) async {
    // При reset начинаем с нуля, при loadMore — берём уже загруженные
    final offset = reset ? 0 : state.projects.length;

    final result = await _getFeedProjects(
      category: state.activeCategory,
      format: state.activeFormat,
      level: state.activeLevel,
      query: state.searchQuery.isEmpty ? null : state.searchQuery,
      offset: offset,
      limit: _kPageSize,
    );

    result.fold(
      onSuccess: (newProjects) {
        final allProjects = reset
            ? newProjects
            : [...state.projects, ...newProjects];
        emit(state.copyWith(
          status: FeedStatus.loaded,
          projects: allProjects,
          hasMore: newProjects.length == _kPageSize,
        ));
      },
      onFailure: (msg) => emit(state.copyWith(
        status: FeedStatus.error,
        errorMessage: msg,
      )),
    );
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}