import 'package:student_app/data/datasources/local_storage_datasource.dart';
import 'package:student_app/data/datasources/project_remote_datasource.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';


class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource _remote;
  final LocalStorageDataSource _local;

  ProjectRepositoryImpl({
    required ProjectRemoteDataSource remote,
    required LocalStorageDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<List<ProjectEntity>> getFeedProjects({
    String? category,
    String? format,
    String? level,
    String? query,
  }) async {
    final models = await _remote.getFeedProjects(
      category: category,
      format: format,
      level: level,
      query: query,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ProjectEntity> getProjectById(String id) async {
    final model = await _remote.getProjectById(id);
    return model.toEntity();
  }

  @override
  Future<ProjectEntity> createProject({
    required String title,
    required String shortDescription,
    required String fullDescription,
    required List<String> skills,
    required int slots,
    required String deadline,
    required String format,
    required String level,
  }) async {
    final model = await _remote.createProject({
      'title': title,
      'short_description': shortDescription,
      'full_description': fullDescription,
      'required_skills': skills,
      'total_slots': slots,
      'deadline': deadline,
      'format': format,
      'level': level,
    });
    return model.toEntity();
  }

  @override
  Future<ProjectEntity> updateProject(String id, Map<String, dynamic> data) async {
    final model = await _remote.updateProject(id, data);
    return model.toEntity();
  }

  @override
  Future<void> deleteProject(String id) => _remote.deleteProject(id);

  @override
  Future<void> toggleFavorite(String projectId) async {
    _local.toggleFavoriteId(projectId);
    await _remote.toggleFavorite(projectId);
  }

  @override
  Future<List<ProjectEntity>> getFavorites() async {
    final models = await _remote.getFavorites();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ProjectEntity>> searchProjects({
    List<String>? skills,
    String? deadline,
    String? format,
    String? level,
    int? maxSlots,
  }) async {
    final models = await _remote.searchProjects({
      if (skills != null && skills.isNotEmpty) 'skills': skills.join(','),
      if (deadline != null) 'deadline': deadline,
      if (format != null) 'format': format,
      if (level != null) 'level': level,
      if (maxSlots != null) 'max_slots': maxSlots,
    });
    return models.map((m) => m.toEntity()).toList();
  }
}