import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_app/core/utils/result.dart';
import 'package:student_app/domain/usecases/project/project_usecases.dart';
import '../../../domain/entities/entities.dart';


part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedProjectsUseCase _getFeedProjects;
  final ToggleFavoriteUseCase _toggleFavorite;

  Timer? _searchDebounce;

  FeedBloc({
    required GetFeedProjectsUseCase getFeedProjects,
    required ToggleFavoriteUseCase toggleFavorite,
  })  : _getFeedProjects = getFeedProjects,
        _toggleFavorite = toggleFavorite,
        super(const FeedState()) {
    on<FeedLoadRequested>(_onLoad);
    on<FeedRefreshRequested>(_onRefresh);
    on<FeedCategoryChanged>(_onCategoryChanged);
    on<FeedFormatChanged>(_onFormatChanged);
    on<FeedSearchChanged>(_onSearchChanged);
    on<FeedFavoriteToggled>(_onFavoriteToggled);
  }

  Future<void> _onLoad(FeedLoadRequested event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.loading));
    await _loadProjects(emit);
  }

  Future<void> _onRefresh(FeedRefreshRequested event, Emitter<FeedState> emit) async {
    await _loadProjects(emit);
  }

  Future<void> _onCategoryChanged(FeedCategoryChanged event, Emitter<FeedState> emit) async {
    emit(state.copyWith(activeCategory: event.category, status: FeedStatus.loading));
    await _loadProjects(emit);
  }

  Future<void> _onFormatChanged(FeedFormatChanged event, Emitter<FeedState> emit) async {
    emit(state.copyWith(activeFormat: event.format, status: FeedStatus.loading));
    await _loadProjects(emit);
  }

  Future<void> _onSearchChanged(FeedSearchChanged event, Emitter<FeedState> emit) async {
    emit(state.copyWith(searchQuery: event.query));
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      add(FeedRefreshRequested());
    });
  }

  Future<void> _onFavoriteToggled(FeedFavoriteToggled event, Emitter<FeedState> emit) async {
    final ids = Set<String>.from(state.favoriteIds);
    // Optimistic update
    if (ids.contains(event.projectId)) {
      ids.remove(event.projectId);
    } else {
      ids.add(event.projectId);
    }
    emit(state.copyWith(favoriteIds: ids));
    // Fire and forget — revert on error if needed
    await _toggleFavorite(event.projectId);
  }

  Future<void> _loadProjects(Emitter<FeedState> emit) async {
    final result = await _getFeedProjects(
      category: state.activeCategory == 'Все' ? null : state.activeCategory,
      format: state.activeFormat == 'Все' ? null : state.activeFormat,
      query: state.searchQuery.isEmpty ? null : state.searchQuery,
    );
    result.fold(
      onSuccess: (projects) => emit(state.copyWith(
        status: FeedStatus.loaded,
        projects: projects,
      )),
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
