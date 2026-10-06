import '../../../../utils/typedefs.dart';
import '../entities/activity_entity.dart';
import '../repositories/activity_repository.dart';

class CreateActivity {
  final ActivityRepository repository;
  CreateActivity(this.repository);

  FutureEither<ActivityEntity> call(CreateActivityParams params) =>
      repository.createActivity(params);
}
