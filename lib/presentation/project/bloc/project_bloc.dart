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

// ─── State ────────────────────────────────────────────────────────────────

enum ProjectStatus { initial, loading, loaded, error }

class ProjectState {
  final ProjectStatus status;
  final ProjectEntity? project;
  final String? errorMessage;

  const ProjectState({
    this.status = ProjectStatus.initial,
    this.project,
    this.errorMessage,
  });

  ProjectState copyWith({
    ProjectStatus? status,
    ProjectEntity? project,
    String? errorMessage,
  }) =>
      ProjectState(
        status: status ?? this.status,
        project: project ?? this.project,
        errorMessage: errorMessage,
      );
}

// ─── BLoC ─────────────────────────────────────────────────────────────────

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetProjectByIdUseCase _getProject;

  ProjectBloc({
    required GetProjectByIdUseCase getProject,
  })  : _getProject = getProject,
        super(const ProjectState()) {
    on<ProjectLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    ProjectLoadRequested event,
    Emitter<ProjectState> emit,
  ) async {
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
}