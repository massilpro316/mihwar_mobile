import '../../../../utils/typedefs.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  /// The signed-in employee's tasks.
  ///
  /// [stationId] narrows them to one farm; omit it for every farm the employee
  /// works on.
  FutureEither<List<TaskEntity>> getTasks({int? stationId});

  /// Completes, cancels or reopens the employee's own assignment and returns
  /// [task] as it now stands.
  ///
  /// Completing a `product` task needs [product]; a `dose` task needs [dose].
  /// The server writes that farm record in the same request.
  FutureEither<TaskEntity> updateStatus({
    required TaskEntity task,
    required TaskStatus status,
    String? note,
    TaskProductRecord? product,
    TaskDoseRecord? dose,
  });

  /// Adds, edits or (with an empty [note]) removes the note on a completed or
  /// cancelled assignment, without touching its status.
  FutureEither<TaskEntity> saveNote({
    required TaskEntity task,
    required String note,
  });
}
