import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/core/constants/app_routes.dart';
import 'package:student_app/presentation/application/pages/application_page.dart';
import 'package:student_app/presentation/applications_management/pages/application_details_page.dart';
import 'package:student_app/presentation/applications_management/pages/applications_management_page.dart';
import 'package:student_app/presentation/common/widgets/main_scaffold.dart';
import 'package:student_app/presentation/create_project/pages/create_project_page.dart';
import 'package:student_app/presentation/edit_project/pages/edit_project_page.dart';
import 'package:student_app/presentation/feed/page/feed_page.dart';
import 'package:student_app/presentation/notifications/pages/notifications_page.dart';
import 'package:student_app/presentation/onboarding/pages/onboarding_page.dart';
import 'package:student_app/presentation/profile/pages/profile_page.dart';
import 'package:student_app/presentation/project/pages/project_page.dart';
import 'package:student_app/presentation/search/pages/search_page.dart';
import 'package:student_app/presentation/settings/pages/settings_page.dart';


class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      // Shell route for bottom nav tabs
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.feed,
            builder: (context, state) => const FeedPage(),
          ),
          GoRoute(
            path: AppRoutes.search,
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (context, state) => const NotificationsPage(),
          ),
        ],
      ),

      // Full-screen routes (outside shell)
      GoRoute(
        path: '/project/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ProjectPage(
          projectId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/project/:id/apply',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ApplicationPage(
          projectId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/project/:id/applications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ApplicationsManagementPage(
          projectId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/project/:id/applications/:appId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ApplicationDetailsPage(
          projectId: state.pathParameters['id']!,
          applicationId: state.pathParameters['appId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.createProject,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateProjectPage(),
      ),
      GoRoute(
        path: '/project/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => EditProjectPage(
          projectId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}