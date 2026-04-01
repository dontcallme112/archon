
// ─── Get Feed Projects ────────────────────────────────────────────────────

import 'package:student_app/core/utils/result.dart';
import 'package:student_app/domain/entities/entities.dart';
import 'package:student_app/domain/repositories/repositories.dart';

class GetFeedProjectsUseCase {
  final ProjectRepository _repo;
  GetFeedProjectsUseCase(this._repo);

  Future<Result<List<ProjectEntity>>> call({
    String? category,
    String? format,
    String? level,
    String? query,
  }) async {
    try {
      final projects = await _repo.getFeedProjects(
        category: category,
        format: format,
        level: level,
        query: query,
      );
      return Success(projects);
    } catch (e) {
      return Failure('Не удалось загрузить проекты', error: e);
    }
  }
}

// ─── Get Project By Id ────────────────────────────────────────────────────

class GetProjectByIdUseCase {
  final ProjectRepository _repo;
  GetProjectByIdUseCase(this._repo);

  Future<Result<ProjectEntity>> call(String id) async {
    try {
      final project = await _repo.getProjectById(id);
      return Success(project);
    } catch (e) {
      return Failure('Не удалось загрузить проект', error: e);
    }
  }
}

// ─── Create Project ───────────────────────────────────────────────────────

class CreateProjectUseCase {
  final ProjectRepository _repo;
  CreateProjectUseCase(this._repo);

  Future<Result<ProjectEntity>> call({
    required String title,
    required String shortDescription,
    required String fullDescription,
    required List<String> skills,
    required int slots,
    required String deadline,
    required String format,
    required String level,
  }) async {
    if (title.trim().isEmpty) {
      return const Failure('Введите название проекта');
    }
    if (skills.isEmpty) {
      return const Failure('Выберите хотя бы один навык');
    }
    try {
      final project = await _repo.createProject(
        title: title.trim(),
        shortDescription: shortDescription.trim(),
        fullDescription: fullDescription.trim(),
        skills: skills,
        slots: slots,
        deadline: deadline,
        format: format,
        level: level,
      );
      return Success(project);
    } catch (e) {
      return Failure('Не удалось создать проект', error: e);
    }
  }
}

// ─── Update Project ───────────────────────────────────────────────────────

class UpdateProjectUseCase {
  final ProjectRepository _repo;
  UpdateProjectUseCase(this._repo);

  Future<Result<ProjectEntity>> call(String id, Map<String, dynamic> data) async {
    try {
      final project = await _repo.updateProject(id, data);
      return Success(project);
    } catch (e) {
      return Failure('Не удалось обновить проект', error: e);
    }
  }
}

// ─── Delete Project ───────────────────────────────────────────────────────

class DeleteProjectUseCase {
  final ProjectRepository _repo;
  DeleteProjectUseCase(this._repo);

  Future<Result<void>> call(String id) async {
    try {
      await _repo.deleteProject(id);
      return const Success(null);
    } catch (e) {
      return Failure('Не удалось удалить проект', error: e);
    }
  }
}

// ─── Toggle Favorite ──────────────────────────────────────────────────────

class ToggleFavoriteUseCase {
  final ProjectRepository _repo;
  ToggleFavoriteUseCase(this._repo);

  Future<Result<void>> call(String projectId) async {
    try {
      await _repo.toggleFavorite(projectId);
      return const Success(null);
    } catch (e) {
      return Failure('Не удалось обновить избранное', error: e);
    }
  }
}

// ─── Search Projects ──────────────────────────────────────────────────────

class SearchProjectsUseCase {
  final ProjectRepository _repo;
  SearchProjectsUseCase(this._repo);

  Future<Result<List<ProjectEntity>>> call({
    List<String>? skills,
    String? deadline,
    String? format,
    String? level,
    int? maxSlots,
  }) async {
    try {
      final projects = await _repo.searchProjects(
        skills: skills,
        deadline: deadline,
        format: format,
        level: level,
        maxSlots: maxSlots,
      );
      return Success(projects);
    } catch (e) {
      return Failure('Поиск не дал результатов', error: e);
    }
  }
}
