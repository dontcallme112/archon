import 'package:student_app/data/datasources/application_remote_datasource.dart';
import 'package:student_app/data/datasources/local_storage_datasource.dart';
import 'package:student_app/data/datasources/user_notification_datasource.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

// ─── Application Repository ───────────────────────────────────────────────

class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationRemoteDataSource _remote;
  ApplicationRepositoryImpl({required ApplicationRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<ApplicationEntity> submitApplication({
    required String projectId,
    required String role,
    required List<String> skills,
    String? portfolioUrl,
    required String motivation,
  }) async {
    final model = await _remote.submitApplication({
      'project_id': projectId,
      'role': role,
      'skills': skills,
      if (portfolioUrl != null) 'portfolio_url': portfolioUrl,
      'motivation': motivation,
    });
    return model.toEntity();
  }

  @override
  Future<List<ApplicationEntity>> getApplicationsForProject(String projectId) async {
    final models = await _remote.getApplicationsForProject(projectId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ApplicationEntity>> getMyApplications() async {
    final models = await _remote.getMyApplications();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ApplicationEntity> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  ) async {
    final statusStr = switch (status) {
      ApplicationStatus.accepted => 'accepted',
      ApplicationStatus.rejected => 'rejected',
      ApplicationStatus.pending => 'pending',
    };
    final model = await _remote.updateApplicationStatus(applicationId, statusStr);
    return model.toEntity();
  }

  @override
  Future<ApplicationEntity> getApplicationById(String id) async {
    final model = await _remote.getApplicationById(id);
    return model.toEntity();
  }
}

// ─── User Repository ──────────────────────────────────────────────────────

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remote;
  final LocalStorageDataSource _local;

  UserRepositoryImpl({
    required UserRemoteDataSource remote,
    required LocalStorageDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final cached = _local.getCachedUser();
    if (cached != null) {
      _refreshCache();
      return _fromCache(cached);
    }
    final model = await _remote.getCurrentUser();
    await _local.saveUser(model.toJson());
    return model.toEntity();
  }

  Future<void> _refreshCache() async {
    try {
      final model = await _remote.getCurrentUser();
      await _local.saveUser(model.toJson());
    } catch (_) {}
  }

  UserEntity _fromCache(Map<String, dynamic> json) => UserEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatar_url'] as String?,
        telegram: json['telegram'] as String?,
        skills: List<String>.from(json['skills'] as List? ?? []),
        level: json['level'] as String? ?? 'junior',
        portfolioUrl: json['portfolio_url'] as String?,
        bio: json['bio'] as String?,
      );

  @override
  Future<UserEntity> updateProfile({
    required List<String> skills,
    required String level,
    String? portfolioUrl,
    String? bio,
    String? telegram,
  }) async {
    final model = await _remote.updateProfile({
      'skills': skills,
      'level': level,
      if (portfolioUrl != null) 'portfolio_url': portfolioUrl,
      if (bio != null) 'bio': bio,
      if (telegram != null) 'telegram': telegram,
    });
    await _local.saveUser(model.toJson());
    return model.toEntity();
  }

  @override
  Future<List<ProjectEntity>> getMyProjects() async {
    final models = await _remote.getMyProjects();
    return models.map((m) => m.toEntity()).toList();
  }
}

// ─── Notification Repository ──────────────────────────────────────────────

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remote;
  NotificationRepositoryImpl({required NotificationRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final models = await _remote.getNotifications();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) =>
      _remote.markAsRead(notificationId);

  @override
  Future<int> getUnreadCount() => _remote.getUnreadCount();
}