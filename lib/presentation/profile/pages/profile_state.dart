import 'package:student_app/domain/entities/entities.dart';

abstract class ProfileState {}

/// Загрузка
class ProfileLoading extends ProfileState {}

/// Успешная загрузка
class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final List<ProjectEntity> projects;
  final List<ApplicationEntity> applications;

  ProfileLoaded({
    required this.user,
    this.projects = const [],
    this.applications = const [],
  });
}

/// Ошибка
class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}