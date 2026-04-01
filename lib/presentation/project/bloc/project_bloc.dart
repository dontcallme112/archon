import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/project/project_usecases.dart';
import '../../../core/utils/result.dart';

// ─── Events ───────────────────────────────────────────────────────────────

abstract class ProjectEvent {}

class ProjectLoadRequested extends ProjectEvent {
  final String projectId;
  ProjectLoadRequested(this.projectId);
}

class ProjectSaveToggled extends ProjectEvent {}

// ─── State ────────────────────────────────────────────────────────────────

enum ProjectStatus { initial, loading, loaded, error }

class ProjectState {
  final ProjectStatus status;
  final ProjectEntity? project;
  final bool isSaved;
  final String? errorMessage;

  const ProjectState({
    this.status = ProjectStatus.initial,
    this.project,
    this.isSaved = false,
    this.errorMessage,
  });

  ProjectState copyWith({
    ProjectStatus? status,
    ProjectEntity? project,
    bool? isSaved,
    String? errorMessage,
  }) =>
      ProjectState(
        status: status ?? this.status,
        project: project ?? this.project,
        isSaved: isSaved ?? this.isSaved,
        errorMessage: errorMessage,
      );
}

// ─── BLoC ─────────────────────────────────────────────────────────────────

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetProjectByIdUseCase _getProject;
  final ToggleFavoriteUseCase _toggleFavorite;

  ProjectBloc({
    required GetProjectByIdUseCase getProject,
    required ToggleFavoriteUseCase toggleFavorite,
  })  : _getProject = getProject,
        _toggleFavorite = toggleFavorite,
        super(const ProjectState()) {
    on<ProjectLoadRequested>(_onLoad);
    on<ProjectSaveToggled>(_onSaveToggled);
  }

  Future<void> _onLoad(ProjectLoadRequested event, Emitter<ProjectState> emit) async {
    emit(state.copyWith(status: ProjectStatus.loading));
    final result = await _getProject(event.projectId);
    result.fold(
      onSuccess: (project) => emit(state.copyWith(
        status: ProjectStatus.loaded,
        project: project,
      )),
      onFailure: (msg) => emit(state.copyWith(
        status: ProjectStatus.error,
        errorMessage: msg,
      )),
    );
  }

  Future<void> _onSaveToggled(ProjectSaveToggled event, Emitter<ProjectState> emit) async {
    emit(state.copyWith(isSaved: !state.isSaved));
    if (state.project != null) {
      await _toggleFavorite(state.project!.id);
    }
  }
}
