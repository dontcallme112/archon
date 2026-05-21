import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:student_app/domain/repositories/firestore_application_repository.dart';
import 'package:student_app/domain/repositories/firestore_project_repository.dart';
import 'package:student_app/domain/repositories/firestore_user_repository.dart';

import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/feed/bloc/feed_bloc.dart';
import 'domain/repositories/repositories.dart';
import 'domain/usecases/other_usecases.dart';
import 'domain/usecases/project/project_usecases.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterNativeSplash.remove();

  runApp(const ProjectHubApp());
}

class ProjectHubApp extends StatelessWidget {
  const ProjectHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProjectRepository>(
          create: (_) => FirestoreProjectRepository(),
        ),
        RepositoryProvider<ApplicationRepository>(
          create: (_) => FirestoreApplicationRepository(),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => FirestoreUserRepository(),
        ),
        RepositoryProvider(
          create: (context) =>
              GetFeedProjectsUseCase(context.read<ProjectRepository>()),
        ),
        RepositoryProvider(
          create: (context) =>
              SubmitApplicationUseCase(context.read<ApplicationRepository>()),
        ),
        RepositoryProvider(
          create: (context) => GetProjectApplicationsUseCase(
            context.read<ApplicationRepository>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => UpdateApplicationStatusUseCase(
            context.read<ApplicationRepository>(),
          ),
        ),
        RepositoryProvider(
          create: (context) =>
              GetCurrentUserUseCase(context.read<UserRepository>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc()..add(AuthCheckRequested()),
          ),
          BlocProvider<FeedBloc>(
            create: (context) => FeedBloc(
              getFeedProjects: context.read<GetFeedProjectsUseCase>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'ProjectHub',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
