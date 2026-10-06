import '../../../../utils/typedefs.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// The employee's tasks, either for one farm or across all of them.
class GetTasks {
  final TaskRepository repository;
  GetTasks(this.repository);

  FutureEither<List<TaskEntity>> call({int? stationId}) =>
      repository.getTasks(stationId: stationId);
}
