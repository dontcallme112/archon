import 'package:dio/dio.dart';
import 'package:student_app/core/network/api_client.dart';
import 'package:student_app/data/models/models.dart';

// ─── User Remote DataSource ───────────────────────────────────────────────

abstract class UserRemoteDataSource {
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<List<ProjectModel>> getMyProjects();
  Future<String> login(String email, String password);
  Future<void> logout();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio _dio;
  UserRemoteDataSourceImpl(ApiClient client) : _dio = client.dio;

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get('/users/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch('/users/me', data: data);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ProjectModel>> getMyProjects() async {
    final response = await _dio.get('/users/me/projects');
    final list = response.data['data'] as List;
    return list.map((j) => ProjectModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<String> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data['token'] as String;
  }

  @override
  Future<void> logout() async => _dio.post('/auth/logout');
}

// ─── Notification Remote DataSource ──────────────────────────────────────

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<int> getUnreadCount();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;
  NotificationRemoteDataSourceImpl(ApiClient client) : _dio = client.dio;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _dio.get('/notifications');
    final list = response.data['data'] as List;
    return list.map((j) => NotificationModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> markAsRead(String id) async =>
      _dio.patch('/notifications/$id/read');

  @override
  Future<int> getUnreadCount() async {
    final response = await _dio.get('/notifications/unread-count');
    return response.data['count'] as int;
  }
}