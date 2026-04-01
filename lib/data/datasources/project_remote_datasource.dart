import 'package:dio/dio.dart';
import 'package:student_app/data/models/models.dart';
import '../../../core/network/api_client.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getFeedProjects({
    String? category,
    String? format,
    String? level,
    String? query,
    int page,
    int limit,
  });
  Future<ProjectModel> getProjectById(String id);
  Future<ProjectModel> createProject(Map<String, dynamic> data);
  Future<ProjectModel> updateProject(String id, Map<String, dynamic> data);
  Future<void> deleteProject(String id);
  Future<void> toggleFavorite(String projectId);
  Future<List<ProjectModel>> getFavorites();
  Future<List<ProjectModel>> searchProjects(Map<String, dynamic> filters);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final Dio _dio;
  ProjectRemoteDataSourceImpl(ApiClient client) : _dio = client.dio;

  @override
  Future<List<ProjectModel>> getFeedProjects({
    String? category,
    String? format,
    String? level,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get('/projects', queryParameters: {
      if (category != null && category != 'Все') 'category': category,
      if (format != null && format != 'Все') 'format': format,
      if (level != null) 'level': level,
      if (query != null && query.isNotEmpty) 'q': query,
      'page': page,
      'limit': limit,
    });
    final list = response.data['data'] as List;
    return list.map((j) => ProjectModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<ProjectModel> getProjectById(String id) async {
    final response = await _dio.get('/projects/$id');
    return ProjectModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProjectModel> createProject(Map<String, dynamic> data) async {
    final response = await _dio.post('/projects', data: data);
    return ProjectModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProjectModel> updateProject(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/projects/$id', data: data);
    return ProjectModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProject(String id) async => _dio.delete('/projects/$id');

  @override
  Future<void> toggleFavorite(String projectId) async =>
      _dio.post('/projects/$projectId/favorite');

  @override
  Future<List<ProjectModel>> getFavorites() async {
    final response = await _dio.get('/projects/favorites');
    final list = response.data['data'] as List;
    return list.map((j) => ProjectModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ProjectModel>> searchProjects(Map<String, dynamic> filters) async {
    final response = await _dio.get('/projects/search', queryParameters: filters);
    final list = response.data['data'] as List;
    return list.map((j) => ProjectModel.fromJson(j as Map<String, dynamic>)).toList();
  }
}