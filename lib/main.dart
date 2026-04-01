import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_app/presentation/feed/bloc/feed_bloc.dart';

import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/notifications/bloc/notifications_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Только портретная ориентация
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Инициализируем все зависимости (DI)
  await initDependencies();

  runApp(const ProjectHubApp());
}

class ProjectHubApp extends StatelessWidget {
  const ProjectHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Глобальные BLoC — живут всё время работы приложения
      providers: [
        BlocProvider<FeedBloc>(
          create: (_) => sl<FeedBloc>()..add(FeedLoadRequested()),
        ),
        BlocProvider<NotificationsBloc>(
          create: (_) =>
              sl<NotificationsBloc>()..add(NotificationsLoadRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: 'ProjectHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}