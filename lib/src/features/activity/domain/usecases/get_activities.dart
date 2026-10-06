import '../../../../utils/typedefs.dart';
import '../entities/activity_entity.dart';
import '../repositories/activity_repository.dart';

class GetActivities {
  final ActivityRepository repository;
  GetActivities(this.repository);

  FutureEither<List<ActivityEntity>> call(int stationId) =>
      repository.getActivities(stationId);
}
