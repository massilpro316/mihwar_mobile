import '../../../../utils/typedefs.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Add, edit or clear the note on a completed or cancelled task.
class SaveTaskNote {
  final TaskRepository repository;
  SaveTaskNote(this.repository);

  FutureEither<TaskEntity> call({
    required TaskEntity task,
    required String note,
  }) =>
      repository.saveNote(task: task, note: note);
}
