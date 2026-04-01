import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/core/network/api_client.dart';
import 'package:student_app/data/datasources/application_remote_datasource.dart';
import 'package:student_app/data/datasources/local_storage_datasource.dart';
import 'package:student_app/data/datasources/project_remote_datasource.dart';
import 'package:student_app/data/datasources/user_notification_datasource.dart';
import 'package:student_app/data/repositories/other_repository_impl.dart';
import 'package:student_app/data/repositories/project_repository_impl.dart';
import 'package:student_app/domain/repositories/repositories.dart';
import 'package:student_app/domain/usecases/other_usecases.dart';
import 'package:student_app/domain/usecases/project/project_usecases.dart';
import 'package:student_app/presentation/applications_management/bloc/app_mgmt_bloc.dart';
import 'package:student_app/presentation/create_project/bloc/create_project_bloc.dart';
import 'package:student_app/presentation/feed/bloc/feed_bloc.dart';
import 'package:student_app/presentation/notifications/bloc/notifications_bloc.dart';
import 'package:student_app/presentation/project/bloc/project_bloc.dart';


final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── External ─────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ─── Core ─────────────────────────────────────────────
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // ─── Local storage ────────────────────────────────────
  sl.registerLazySingleton<LocalStorageDataSource>(
    () => LocalStorageDataSource(sl()),
  );

  // ─── Remote datasources ───────────────────────────────
  sl.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ApplicationRemoteDataSource>(
    () => ApplicationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );

  // ─── Repositories ─────────────────────────────────────
  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(
      remote: sl(),
      local: sl(),
    ),
  );
  sl.registerLazySingleton<ApplicationRepository>(
    () => ApplicationRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remote: sl(), local: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remote: sl()),
  );

  // ─── Use cases ────────────────────────────────────────
  sl.registerLazySingleton(() => GetFeedProjectsUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateProjectUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProjectUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProjectUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => SearchProjectsUseCase(sl()));

  sl.registerLazySingleton(() => SubmitApplicationUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectApplicationsUseCase(sl()));
  sl.registerLazySingleton(() => GetMyApplicationsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateApplicationStatusUseCase(sl()));

  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));

  // ─── BLoC (factory — новый экземпляр на каждый экран) ─
  sl.registerFactory(() => FeedBloc(
        getFeedProjects: sl(),
        toggleFavorite: sl(),
      ));

  sl.registerFactory(() => ProjectBloc(
        getProject: sl(),
        toggleFavorite: sl(),
      ));

  sl.registerFactory(() => AppMgmtBloc(
        getApplications: sl(),
        updateStatus: sl(),
      ));

  sl.registerFactory(() => CreateProjectBloc(createProject: sl()));

  sl.registerFactory(() => NotificationsBloc(
        getNotifications: sl(),
        repo: sl(),
      ));
}