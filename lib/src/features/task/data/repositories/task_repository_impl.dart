import '../../../../utils/typedefs.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;
  const TaskRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<List<TaskEntity>> getTasks({int? stationId}) async {
    final result = await _remoteDataSource.getTasks(stationId: stationId);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  FutureEither<TaskEntity> updateStatus({
    required TaskEntity task,
    required TaskStatus status,
    String? note,
    TaskProductRecord? product,
    TaskDoseRecord? dose,
  }) async {
    final body = <String, dynamic>{
      'status': status.apiValue,
      'note': note?.trim() ?? '',
      if (product != null)
        'product': {
          'material_type': product.materialType.trim(),
          'brand': product.brand.trim(),
          'quantity': product.quantity.trim(),
          'quantity_unit': product.quantityUnit?.trim() ?? '',
          if (product.date != null)
            'creation_date': product.date!.toIso8601String(),
        },
      if (dose != null)
        'dose': {
          'quantity': dose.quantity.trim(),
          if (dose.date != null) 'creation_date': dose.date!.toIso8601String(),
        },
    };

    final result = await _remoteDataSource.updateStatus(task.id, body);
    return result.map((data) {
      final assignment = data['assignment'] is Map
          ? data['assignment'] as Map
          : const <String, dynamic>{};
      final trimmed = note?.trim() ?? '';
      final completing = status == TaskStatus.completed;

      // The server clears any station cancel whenever the employee moves
      // their own assignment, and stamps `completed_at` only on completion.
      return task.copyWith(
        status: status,
        note: trimmed.isEmpty ? null : trimmed,
        clearNote: trimmed.isEmpty,
        completedAt: assignment['completed_at']?.toString() ??
            (completing ? DateTime.now().toIso8601String() : null),
        clearCompletedAt: !completing,
        clearCancellation: true,
        // What was just written to the farm — the server's copy when it sends
        // one, otherwise what the employee typed.
        recordedProduct: completing
            ? productRecordFromJson(data['product']) ?? product
            : null,
        recordedDose:
            completing ? doseRecordFromJson(data['dose']) ?? dose : null,
      );
    });
  }

  @override
  FutureEither<TaskEntity> saveNote({
    required TaskEntity task,
    required String note,
  }) async {
    final trimmed = note.trim();
    final result = await _remoteDataSource.saveNote(task.id, trimmed);
    return result.map(
      (_) => task.copyWith(
        note: trimmed.isEmpty ? null : trimmed,
        clearNote: trimmed.isEmpty,
      ),
    );
  }
}
