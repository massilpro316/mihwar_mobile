abstract final class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String firmDetail = '/firm/:id';
  static const String addProduct = '/add-product';
  static const String taskDetail = '/task/:id';

  static String firmDetailPath(int id) => '/firm/$id';
  static String taskDetailPath(int id) => '/task/$id';
}

/// Which tab the home route opens on.
///
/// Passed as `extra` — `context.go(AppRoutes.home, extra: HomeTab.profile)` —
/// so a choice tile can land the user directly where they asked to go instead
/// of dropping them on the default tab to hunt for it.
/// Order matters: the built-in `index` is used to select the tab, so these must
/// stay in the same order as the destinations in `MainNavigationScreen`.
enum HomeTab { farms, tasks, profile }
