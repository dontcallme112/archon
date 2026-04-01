import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/other_usecases.dart';
import '../../../core/utils/result.dart';

// ─── Events ───────────────────────────────────────────────────────────────

abstract class AppMgmtEvent {}

class AppMgmtLoadRequested extends AppMgmtEvent {
  final String projectId;
  AppMgmtLoadRequested(this.projectId);
}

class AppMgmtApplicationAccepted extends AppMgmtEvent {
  final String applicationId;
  AppMgmtApplicationAccepted(this.applicationId);
}

class AppMgmtApplicationRejected extends AppMgmtEvent {
  final String applicationId;
  AppMgmtApplicationRejected(this.applicationId);
}

// ─── State ────────────────────────────────────────────────────────────────

enum AppMgmtStatus { initial, loading, loaded, error }

class AppMgmtState {
  final AppMgmtStatus status;
  final List<ApplicationEntity> applications;
  final String? errorMessage;
  final String? successMessage;

  const AppMgmtState({
    this.status = AppMgmtStatus.initial,
    this.applications = const [],
    this.errorMessage,
    this.successMessage,
  });

  List<ApplicationEntity> get pending =>
      applications.where((a) => a.status == ApplicationStatus.pending).toList();
  List<ApplicationEntity> get accepted =>
      applications.where((a) => a.status == ApplicationStatus.accepted).toList();
  List<ApplicationEntity> get rejected =>
      applications.where((a) => a.status == ApplicationStatus.rejected).toList();

  AppMgmtState copyWith({
    AppMgmtStatus? status,
    List<ApplicationEntity>? applications,
    String? errorMessage,
    String? successMessage,
  }) =>
      AppMgmtState(
        status: status ?? this.status,
        applications: applications ?? this.applications,
        errorMessage: errorMessage,
        successMessage: successMessage,
      );
}

// ─── BLoC ─────────────────────────────────────────────────────────────────

class AppMgmtBloc extends Bloc<AppMgmtEvent, AppMgmtState> {
  final GetProjectApplicationsUseCase _getApplications;
  final UpdateApplicationStatusUseCase _updateStatus;

  AppMgmtBloc({
    required GetProjectApplicationsUseCase getApplications,
    required UpdateApplicationStatusUseCase updateStatus,
  })  : _getApplications = getApplications,
        _updateStatus = updateStatus,
        super(const AppMgmtState()) {
    on<AppMgmtLoadRequested>(_onLoad);
    on<AppMgmtApplicationAccepted>(_onAccepted);
    on<AppMgmtApplicationRejected>(_onRejected);
  }

  Future<void> _onLoad(AppMgmtLoadRequested event, Emitter<AppMgmtState> emit) async {
    emit(state.copyWith(status: AppMgmtStatus.loading));
    final result = await _getApplications(event.projectId);
    result.fold(
      onSuccess: (apps) => emit(state.copyWith(
        status: AppMgmtStatus.loaded,
        applications: apps,
      )),
      onFailure: (msg) => emit(state.copyWith(
        status: AppMgmtStatus.error,
        errorMessage: msg,
      )),
    );
  }

  Future<void> _onAccepted(AppMgmtApplicationAccepted event, Emitter<AppMgmtState> emit) async {
    await _updateStatusLocal(event.applicationId, ApplicationStatus.accepted, emit);
  }

  Future<void> _onRejected(AppMgmtApplicationRejected event, Emitter<AppMgmtState> emit) async {
    await _updateStatusLocal(event.applicationId, ApplicationStatus.rejected, emit);
  }

  Future<void> _updateStatusLocal(
    String id,
    ApplicationStatus status,
    Emitter<AppMgmtState> emit,
  ) async {
    // Optimistic update
    final updated = state.applications.map((a) {
      if (a.id == id) {
        return ApplicationEntity(
          id: a.id,
          projectId: a.projectId,
          projectTitle: a.projectTitle,
          applicant: a.applicant,
          role: a.role,
          skills: a.skills,
          portfolioUrl: a.portfolioUrl,
          motivation: a.motivation,
          status: status,
          createdAt: a.createdAt,
        );
      }
      return a;
    }).toList();

    emit(state.copyWith(
      applications: updated,
      successMessage: status == ApplicationStatus.accepted
          ? 'Кандидат принят в команду!'
          : 'Заявка отклонена',
    ));

    // Sync with API
    await _updateStatus(id, status);
  }
}
