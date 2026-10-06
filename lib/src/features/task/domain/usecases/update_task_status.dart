import '../../../../utils/typedefs.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Complete, cancel (refuse) or reopen the employee's own task.
class UpdateTaskStatus {
  final TaskRepository repository;
  UpdateTaskStatus(this.repository);

  FutureEither<TaskEntity> call({
    required TaskEntity task,
    required TaskStatus status,
    String? note,
    TaskProductRecord? product,
    TaskDoseRecord? dose,
  }) =>
      repository.updateStatus(
        task: task,
        status: status,
        note: note,
        product: product,
        dose: dose,
      );
}
