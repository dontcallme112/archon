
import 'package:student_app/domain/entities/entities.dart';
import 'package:student_app/domain/repositories/repositories.dart';

import '../../../core/utils/result.dart';

// ─── Submit Application ───────────────────────────────────────────────────

class SubmitApplicationUseCase {
  final ApplicationRepository _repo;
  SubmitApplicationUseCase(this._repo);

  Future<Result<ApplicationEntity>> call({
    required String projectId,
    required String role,
    required List<String> skills,
    String? portfolioUrl,
    required String motivation,
  }) async {
    if (role.trim().isEmpty) return const Failure('Выберите роль');
    if (motivation.trim().isEmpty) return const Failure('Заполните мотивацию');
    try {
      final app = await _repo.submitApplication(
        projectId: projectId,
        role: role,
        skills: skills,
        portfolioUrl: portfolioUrl,
        motivation: motivation,
      );
      return Success(app);
    } catch (e) {
      return Failure('Не удалось отправить заявку', error: e);
    }
  }
}

// ─── Get Applications For Project ─────────────────────────────────────────

class GetProjectApplicationsUseCase {
  final ApplicationRepository _repo;
  GetProjectApplicationsUseCase(this._repo);

  Future<Result<List<ApplicationEntity>>> call(String projectId) async {
    try {
      final apps = await _repo.getApplicationsForProject(projectId);
      return Success(apps);
    } catch (e) {
      return Failure('Не удалось загрузить заявки', error: e);
    }
  }
}

// ─── Get My Applications ──────────────────────────────────────────────────

class GetMyApplicationsUseCase {
  final ApplicationRepository _repo;
  GetMyApplicationsUseCase(this._repo);

  Future<Result<List<ApplicationEntity>>> call() async {
    try {
      final apps = await _repo.getMyApplications();
      return Success(apps);
    } catch (e) {
      return Failure('Не удалось загрузить мои заявки', error: e);
    }
  }
}

// ─── Update Application Status ────────────────────────────────────────────

class UpdateApplicationStatusUseCase {
  final ApplicationRepository _repo;
  UpdateApplicationStatusUseCase(this._repo);

  Future<Result<ApplicationEntity>> call(
    String applicationId,
    ApplicationStatus status,
  ) async {
    try {
      final app = await _repo.updateApplicationStatus(applicationId, status);
      return Success(app);
    } catch (e) {
      return Failure('Не удалось обновить статус заявки', error: e);
    }
  }
}

// ─── Get Current User ─────────────────────────────────────────────────────

class GetCurrentUserUseCase {
  final UserRepository _repo;
  GetCurrentUserUseCase(this._repo);

  Future<Result<UserEntity?>> call() async {
    try {
      final user = await _repo.getCurrentUser();
      return Success(user);
    } catch (e) {
      return Failure('Не удалось загрузить профиль', error: e);
    }
  }
}

// ─── Update Profile ───────────────────────────────────────────────────────

class UpdateProfileUseCase {
  final UserRepository _repo;
  UpdateProfileUseCase(this._repo);

  Future<Result<UserEntity>> call({
    required List<String> skills,
    required String level,
    String? portfolioUrl,
    String? bio,
    String? telegram,
  }) async {
    if (skills.isEmpty) return const Failure('Добавьте хотя бы один навык');
    try {
      final user = await _repo.updateProfile(
        skills: skills,
        level: level,
        portfolioUrl: portfolioUrl,
        bio: bio,
        telegram: telegram,
      );
      return Success(user);
    } catch (e) {
      return Failure('Не удалось обновить профиль', error: e);
    }
  }
}

// ─── Get Notifications ────────────────────────────────────────────────────

class GetNotificationsUseCase {
  final NotificationRepository _repo;
  GetNotificationsUseCase(this._repo);

  Future<Result<List<NotificationEntity>>> call() async {
    try {
      final notifications = await _repo.getNotifications();
      return Success(notifications);
    } catch (e) {
      return Failure('Не удалось загрузить уведомления', error: e);
    }
  }
}
