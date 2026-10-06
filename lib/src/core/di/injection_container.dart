import 'package:get_it/get_it.dart';

import '../../features/farm/data/datasources/farm_remote_datasource.dart';
import '../../features/farm/data/repositories/farm_repository_impl.dart';
import '../../features/farm/domain/repositories/farm_repository.dart';
import '../../features/farm/domain/usecases/get_farms.dart';
import '../../features/farm/presentation/providers/farm_bloc.dart';

import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/create_product.dart';
import '../../features/product/domain/usecases/delete_product.dart';
import '../../features/product/domain/usecases/get_products.dart';
import '../../features/product/presentation/providers/product_bloc.dart';

import '../../features/activity/data/datasources/activity_remote_datasource.dart';
import '../../features/activity/data/repositories/activity_repository_impl.dart';
import '../../features/activity/domain/repositories/activity_repository.dart';
import '../../features/activity/domain/usecases/create_activity.dart';
import '../../features/activity/domain/usecases/get_activities.dart';
import '../../features/activity/presentation/providers/activity_bloc.dart';

import '../../features/task/data/datasources/task_remote_datasource.dart';
import '../../features/task/data/repositories/task_repository_impl.dart';
import '../../features/task/domain/repositories/task_repository.dart';
import '../../features/task/domain/entities/task_entity.dart';
import '../../features/task/domain/usecases/get_tasks.dart';
import '../../features/task/domain/usecases/save_task_note.dart';
import '../../features/task/domain/usecases/update_task_status.dart';
import '../../features/task/presentation/providers/task_bloc.dart';
import '../../features/task/presentation/providers/task_detail_bloc.dart';

import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/presentation/providers/profile_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  if (getIt.isRegistered<FarmBloc>()) return;

  // ─── Farm ─────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<FarmRemoteDataSource>(
      () => FarmRemoteDataSourceImpl());
  getIt
      .registerLazySingleton<FarmRepository>(() => FarmRepositoryImpl(getIt()));
  getIt.registerLazySingleton(() => GetFarms(getIt()));
  getIt.registerFactory(() => FarmBloc(getFarms: getIt()));

  // ─── Product ──────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl());
  getIt.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(getIt()));
  getIt.registerLazySingleton(() => GetProducts(getIt()));
  getIt.registerLazySingleton(() => CreateProduct(getIt()));
  getIt.registerLazySingleton(() => DeleteProduct(getIt()));
  getIt.registerFactory(() => ProductBloc(
        getProducts: getIt(),
        createProduct: getIt(),
        deleteProduct: getIt(),
      ));

  // ─── Activity ─────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<ActivityRemoteDataSource>(
      () => ActivityRemoteDataSourceImpl());
  getIt.registerLazySingleton<ActivityRepository>(
      () => ActivityRepositoryImpl(getIt()));
  getIt.registerLazySingleton(() => GetActivities(getIt()));
  getIt.registerLazySingleton(() => CreateActivity(getIt()));
  getIt.registerFactory(() => ActivityBloc(
        getActivities: getIt(),
        createActivity: getIt(),
      ));

  // ─── Task ─────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<TaskRemoteDataSource>(
      () => TaskRemoteDataSourceImpl());
  getIt
      .registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(getIt()));
  getIt.registerLazySingleton(() => GetTasks(getIt()));
  // A factory, not a singleton: the farm screen and the all-tasks screen each
  // hold their own scoped list at the same time.
  getIt.registerFactory(() => TaskBloc(getTasks: getIt()));
  getIt.registerLazySingleton(() => UpdateTaskStatus(getIt()));
  getIt.registerLazySingleton(() => SaveTaskNote(getIt()));
  // One per task page, seeded with the task the employee tapped.
  getIt.registerFactoryParam<TaskDetailBloc, TaskEntity, void>(
    (task, _) => TaskDetailBloc(
      task: task,
      updateTaskStatus: getIt(),
      saveTaskNote: getIt(),
    ),
  );

  // ─── Profile ──────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl());
  getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt()));
  getIt.registerLazySingleton(() => GetProfile(getIt()));
  getIt.registerLazySingleton(() => UpdateProfile(getIt()));
  getIt.registerFactory(() => ProfileBloc(
        getProfile: getIt(),
        updateProfile: getIt(),
      ));
}
