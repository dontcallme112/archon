class UserEntity {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? telegram;
  final List<String> skills;
  final String level; // junior / middle / senior
  final String? portfolioUrl;
  final String? bio;

  const UserEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.telegram,
    required this.skills,
    required this.level,
    this.portfolioUrl,
    this.bio,
  });
}

class ProjectEntity {
  final String id;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final List<String> requiredSkills;
  final String deadline;
  final String format; // online / offline
  final String level; // junior / middle / senior
  final int totalSlots;
  final int filledSlots;
  final UserEntity author;
  final List<UserEntity> teamMembers;
  final String category; // design / dev / marketing
  final bool isActive;
  final DateTime createdAt;

  const ProjectEntity({
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

  int get freeSlots => totalSlots - filledSlots;
}

class ApplicationEntity {
  final String id;
  final String projectId;
  final String projectTitle;
  final UserEntity applicant;
  final String role;
  final List<String> skills;
  final String? portfolioUrl;
  final String motivation;
  final ApplicationStatus status;
  final DateTime createdAt;

  const ApplicationEntity({
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
}

enum ApplicationStatus { pending, accepted, rejected }

class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });
}

enum NotificationType { applicationAccepted, applicationRejected, newMessage, newProject }