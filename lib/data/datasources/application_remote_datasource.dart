import 'package:dio/dio.dart';
import 'package:student_app/data/models/models.dart';
import '../../../core/network/api_client.dart';

abstract class ApplicationRemoteDataSource {
  Future<ApplicationModel> submitApplication(Map<String, dynamic> data);
  Future<List<ApplicationModel>> getApplicationsForProject(String projectId);
  Future<List<ApplicationModel>> getMyApplications();
  Future<ApplicationModel> updateApplicationStatus(String id, String status);
  Future<ApplicationModel> getApplicationById(String id);
}

class ApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  final Dio _dio;
  ApplicationRemoteDataSourceImpl(ApiClient client) : _dio = client.dio;

  @override
  Future<ApplicationModel> submitApplication(Map<String, dynamic> data) async {
    final response = await _dio.post('/applications', data: data);
    return ApplicationModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ApplicationModel>> getApplicationsForProject(String projectId) async {
    final response = await _dio.get('/projects/$projectId/applications');
    final list = response.data['data'] as List;
    return list.map((j) => ApplicationModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ApplicationModel>> getMyApplications() async {
    final response = await _dio.get('/applications/my');
    final list = response.data['data'] as List;
    return list.map((j) => ApplicationModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<ApplicationModel> updateApplicationStatus(String id, String status) async {
    final response = await _dio.patch('/applications/$id/status', data: {'status': status});
    return ApplicationModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ApplicationModel> getApplicationById(String id) async {
    final response = await _dio.get('/applications/$id');
    return ApplicationModel.fromJson(response.data as Map<String, dynamic>);
  }
}