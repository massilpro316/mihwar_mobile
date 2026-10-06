import 'package:go_router/go_router.dart';
import 'package:mihwar/src/routing/global_navigator.dart';
import 'package:mihwar/src/routing/app_routes.dart';

import 'package:mihwar/src/features/auth/presentation/screens/splash_screen.dart';
import 'package:mihwar/src/features/auth/presentation/screens/login_screen.dart';
import 'package:mihwar/src/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:mihwar/src/features/farm/domain/entities/farm_entity.dart';
import 'package:mihwar/src/features/farm/presentation/screens/firm_detail_screen.dart';
import 'package:mihwar/src/features/product/presentation/screens/add_product_screen.dart';
import 'package:mihwar/src/features/task/domain/entities/task_entity.dart';
import 'package:mihwar/src/features/task/presentation/screens/task_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => MainNavigationScreen(
        initialTab:
            state.extra is HomeTab ? state.extra! as HomeTab : HomeTab.farms,
      ),
    ),
    GoRoute(
      path: AppRoutes.firmDetail,
      name: 'firmDetail',
      builder: (context, state) =>
          FirmDetailScreen(farm: state.extra! as FarmEntity),
    ),
    GoRoute(
      path: AppRoutes.addProduct,
      name: 'addProduct',
      builder: (context, state) =>
          AddProductScreen(farmId: state.extra! as int),
    ),
    GoRoute(
      path: AppRoutes.taskDetail,
      name: 'taskDetail',
      builder: (context, state) =>
          TaskDetailScreen(task: state.extra! as TaskEntity),
    ),
  ],
);
