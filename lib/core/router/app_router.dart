import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../presentation/auth/pages/login_page.dart';
import '../../presentation/auth/pages/register_page.dart';
import '../../presentation/feed/pages/feed_page.dart';
import '../../presentation/onboarding/pages/onboarding_page.dart';
import '../../presentation/project/pages/project_page.dart';
import '../../presentation/application/pages/application_page.dart';
import '../../presentation/applications_management/pages/applications_management_page.dart';
import '../../presentation/applications_management/pages/application_details_page.dart';
import '../../presentation/create_project/pages/create_project_page.dart';
import '../../presentation/edit_project/pages/edit_project_page.dart';
import '../../presentation/profile/pages/profile_page.dart';
import '../../presentation/search/pages/search_page.dart';
import '../../presentation/notifications/pages/notifications_page.dart';
import '../../presentation/settings/pages/settings_page.dart';
import '../../presentation/common/widgets/main_scaffold.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',

    // ─── Auth guard ──────────────────────────────────────────
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final location = state.matchedLocation;

      final protectedRoutes = [
        '/project/create',
        '/profile',
        '/notifications',
      ];

      final isAuthRoute = location == '/login' || location == '/register';
      final isProtected = protectedRoutes.any((r) => location.startsWith(r));

      if (!isLoggedIn && isProtected) return '/login';
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/feed';

      return null;
    },
    routes: [
      // ─── Auth routes ────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // ─── Onboarding (после регистрации) ─────────────────────
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingPage(),
      ),

      // ─── Shell (bottom nav) ──────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/feed',
            builder: (context, state) => const FeedPage(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
        ],
      ),

      // ─── Full-screen routes ──────────────────────────────────
      GoRoute(
        path: '/project/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            ProjectPage(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/project/:id/apply',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            ApplicationPage(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/project/:id/applications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            ApplicationsManagementPage(projectId: state.pathParameters['id']!),
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
        path: '/project/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateProjectPage(),
      ),
      GoRoute(
        path: '/project/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            EditProjectPage(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
