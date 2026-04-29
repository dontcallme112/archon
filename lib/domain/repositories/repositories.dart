import '../entities/entities.dart';

abstract class ProjectRepository {
  Future<List<ProjectEntity>> getFeedProjects({
    String? category,
    String? format,
    String? level,
    String? query,
    int offset = 0,  // ← дефолтные значения
    int limit = 10,
  });

  Future<ProjectEntity> getProjectById(String id);

  Future<ProjectEntity> createProject({
    required String title,
    required String shortDescription,
    required String fullDescription,
    required List<String> skills,
    required int slots,
    required String deadline,
    required String format,
    required String level,
    required String category,
  });

  Future<ProjectEntity> updateProject(String id, Map<String, dynamic> data);

  Future<void> deleteProject(String id);

  Future<void> toggleFavorite(String projectId);

  Future<List<ProjectEntity>> getFavorites();

  Future<List<ProjectEntity>> searchProjects({
    List<String>? skills,
    String? deadline,
    String? format,
    String? level,
    int? maxSlots,
  });
}

abstract class ApplicationRepository {
  Future<ApplicationEntity> submitApplication({
    required String projectId,
    required String role,
    required List<String> skills,
    String? portfolioUrl,
    required String motivation,
  });

  Future<List<ApplicationEntity>> getApplicationsForProject(String projectId);

  Future<List<ApplicationEntity>> getMyApplications();

  Future<ApplicationEntity> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  );

  Future<ApplicationEntity> getApplicationById(String id);
}

abstract class UserRepository {
  Future<UserEntity?> getCurrentUser();

  Future<UserEntity> updateProfile({
    required List<String> skills,
    required String level,
    String? portfolioUrl,
    String? bio,
    String? telegram,
  });

  Future<List<ProjectEntity>> getMyProjects();
}

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();

  Future<void> markAsRead(String notificationId);

  Future<int> getUnreadCount();
}