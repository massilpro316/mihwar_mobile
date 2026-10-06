import '../../../../utils/typedefs.dart';
import '../entities/activity_entity.dart';

abstract class ActivityRepository {
  FutureEither<List<ActivityEntity>> getActivities(int stationId);
  FutureEither<ActivityEntity> createActivity(CreateActivityParams params);
}
