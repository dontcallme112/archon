import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/project/project_usecases.dart';
import '../../../core/utils/result.dart';

// ─── Events ───────────────────────────────────────────────────────────────

abstract class CreateProjectEvent {}

class CreateProjectStepChanged extends CreateProjectEvent {
  final int step;
  CreateProjectStepChanged(this.step);
}

class CreateProjectPublished extends CreateProjectEvent {
  final String title;
  final String shortDescription;
  final String fullDescription;
  final List<String> skills;
  final int slots;
  final String deadline;
  final String format;
  final String level;
  final String category;

  CreateProjectPublished({
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.skills,
    required this.slots,
    required this.deadline,
    required this.format,
    required this.level,
    required this.category,
  });
}

// ─── State ────────────────────────────────────────────────────────────────

enum CreateProjectStatus { idle, loading, success, error }

class CreateProjectState {
  final CreateProjectStatus status;
  final int currentStep;
  final ProjectEntity? createdProject;
  final String? errorMessage;

  const CreateProjectState({
    this.status = CreateProjectStatus.idle,
    this.currentStep = 0,
    this.createdProject,
    this.errorMessage,
  });

  CreateProjectState copyWith({
    CreateProjectStatus? status,
    int? currentStep,
    ProjectEntity? createdProject,
    String? errorMessage,
  }) =>
      CreateProjectState(
        status: status ?? this.status,
        currentStep: currentStep ?? this.currentStep,
        createdProject: createdProject ?? this.createdProject,
        errorMessage: errorMessage,
      );
}

// ─── BLoC ─────────────────────────────────────────────────────────────────

class CreateProjectBloc
    extends Bloc<CreateProjectEvent, CreateProjectState> {
  final CreateProjectUseCase _createProject;

  CreateProjectBloc({required CreateProjectUseCase createProject})
      : _createProject = createProject,
        super(const CreateProjectState()) {
    on<CreateProjectStepChanged>(_onStepChanged);
    on<CreateProjectPublished>(_onPublished);
  }

  void _onStepChanged(
    CreateProjectStepChanged event,
    Emitter<CreateProjectState> emit,
  ) {
    emit(state.copyWith(currentStep: event.step));
  }

  Future<void> _onPublished(
    CreateProjectPublished event,
    Emitter<CreateProjectState> emit,
  ) async {
    emit(state.copyWith(status: CreateProjectStatus.loading));
    final result = await _createProject(
      title: event.title,
      shortDescription: event.shortDescription,
      fullDescription: event.fullDescription,
      skills: event.skills,
      slots: event.slots,
      deadline: event.deadline,
      format: event.format,
      level: event.level,
      category: event.category,
    );
    result.fold(
      onSuccess: (project) => emit(state.copyWith(
        status: CreateProjectStatus.success,
        createdProject: project,
      )),
      onFailure: (msg) => emit(state.copyWith(
        status: CreateProjectStatus.error,
        errorMessage: msg,
      )),
    );
  }
}