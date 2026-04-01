abstract class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const feed = '/feed';
  static const project = '/project/:id';
  static const application = '/project/:id/apply';
  static const createProject = '/project/create';
  static const editProject = '/project/:id/edit';
  static const applicationsManagement = '/project/:id/applications';
  static const applicationDetails = '/project/:id/applications/:appId';
  static const profile = '/profile';
  static const search = '/search';
  static const notifications = '/notifications';
  static const settings = '/settings';
}