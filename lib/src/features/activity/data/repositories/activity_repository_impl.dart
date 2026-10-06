import '../../domain/entities/activity_entity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../../../utils/typedefs.dart';
import '../datasources/activity_remote_datasource.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource _remoteDataSource;
  const ActivityRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<List<ActivityEntity>> getActivities(int stationId) async {
    final result = await _remoteDataSource.getActivities(stationId);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  FutureEither<ActivityEntity> createActivity(
      CreateActivityParams params) async {
    final result = await _remoteDataSource.createActivity(params);
    return result.map((m) => m.toEntity());
  }
}
