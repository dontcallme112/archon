import '../../domain/entities/entities.dart';

// ─── User Model ───────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? telegram;
  final List<String> skills;
  final String level;
  final String? portfolioUrl;
  final String? bio;

  const UserModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.telegram,
    required this.skills,
    required this.level,
    this.portfolioUrl,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatar_url'] as String?,
        telegram: json['telegram'] as String?,
        skills: List<String>.from(json['skills'] as List? ?? []),
        level: json['level'] as String? ?? 'junior',
        portfolioUrl: json['portfolio_url'] as String?,
        bio: json['bio'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar_url': avatarUrl,
        'telegram': telegram,
        'skills': skills,
        'level': level,
        'portfolio_url': portfolioUrl,
        'bio': bio,
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        avatarUrl: avatarUrl,
        telegram: telegram,
        skills: skills,
        level: level,
        portfolioUrl: portfolioUrl,
        bio: bio,
      );
}

// ─── Project Model ────────────────────────────────────────────────────────

class ProjectModel {
  final String id;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final List<String> requiredSkills;
  final String deadline;
  final String format;
  final String level;
  final int totalSlots;
  final int filledSlots;
  final UserModel author;
  final List<UserModel> teamMembers;
  final String category;
  final bool isActive;
  final String createdAt;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.requiredSkills,
    required this.deadline,
    required this.format,
    required this.level,
    required this.totalSlots,
    required this.filledSlots,
    required this.author,
    required this.teamMembers,
    required this.category,
    required this.isActive,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as String,
        title: json['title'] as String,
        shortDescription: json['short_description'] as String,
        fullDescription: json['full_description'] as String,
        requiredSkills: List<String>.from(json['required_skills'] as List? ?? []),
        deadline: json['deadline'] as String,
        format: json['format'] as String,
        level: json['level'] as String,
        totalSlots: json['total_slots'] as int,
        filledSlots: json['filled_slots'] as int,
        author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
        teamMembers: (json['team_members'] as List? ?? [])
            .map((m) => UserModel.fromJson(m as Map<String, dynamic>))
            .toList(),
        category: json['category'] as String,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] as String,
      );

  ProjectEntity toEntity() => ProjectEntity(
        id: id,
        title: title,
        shortDescription: shortDescription,
        fullDescription: fullDescription,
        requiredSkills: requiredSkills,
        deadline: deadline,
        format: format,
        level: level,
        totalSlots: totalSlots,
        filledSlots: filledSlots,
        author: author.toEntity(),
        teamMembers: teamMembers.map((m) => m.toEntity()).toList(),
        category: category,
        isActive: isActive,
        createdAt: DateTime.parse(createdAt),
      );
}

// ─── Application Model ────────────────────────────────────────────────────

class ApplicationModel {
  final String id;
  final String projectId;
  final String projectTitle;
  final UserModel applicant;
  final String role;
  final List<String> skills;
  final String? portfolioUrl;
  final String motivation;
  final String status;
  final String createdAt;

  const ApplicationModel({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.applicant,
    required this.role,
    required this.skills,
    this.portfolioUrl,
    required this.motivation,
    required this.status,
    required this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) => ApplicationModel(
        id: json['id'] as String,
        projectId: json['project_id'] as String,
        projectTitle: json['project_title'] as String,
        applicant: UserModel.fromJson(json['applicant'] as Map<String, dynamic>),
        role: json['role'] as String,
        skills: List<String>.from(json['skills'] as List? ?? []),
        portfolioUrl: json['portfolio_url'] as String?,
        motivation: json['motivation'] as String,
        status: json['status'] as String,
        createdAt: json['created_at'] as String,
      );

  ApplicationEntity toEntity() => ApplicationEntity(
        id: id,
        projectId: projectId,
        projectTitle: projectTitle,
        applicant: applicant.toEntity(),
        role: role,
        skills: skills,
        portfolioUrl: portfolioUrl,
        motivation: motivation,
        status: _parseStatus(status),
        createdAt: DateTime.parse(createdAt),
      );

  static ApplicationStatus _parseStatus(String s) => switch (s) {
        'accepted' => ApplicationStatus.accepted,
        'rejected' => ApplicationStatus.rejected,
        _ => ApplicationStatus.pending,
      };
}

// ─── Notification Model ────────────────────────────────────────────────────

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String? ?? '',
        type: json['type'] as String,
        createdAt: json['created_at'] as String,
        isRead: json['is_read'] as bool? ?? false,
      );

  NotificationEntity toEntity() => NotificationEntity(
        id: id,
        title: title,
        message: message,
        type: _parseType(type),
        createdAt: DateTime.parse(createdAt),
        isRead: isRead,
      );

  static NotificationType _parseType(String t) => switch (t) {
        'application_accepted' => NotificationType.applicationAccepted,
        'application_rejected' => NotificationType.applicationRejected,
        'new_message' => NotificationType.newMessage,
        _ => NotificationType.newProject,
      };
}
