import 'package:equatable/equatable.dart';

/// How far along one employee's copy of a task is.
///
/// The API sends these as `Pending` / `Completed` / `Cancelled`; anything it
/// does not recognise falls back to [pending] rather than throwing, so a new
/// status added on the server can never blank the screen for a farmer.
enum TaskStatus {
  pending,
  completed,
  cancelled;

  /// The exact value `POST /api/tasks/:id/status` expects.
  String get apiValue => switch (this) {
        TaskStatus.pending => 'Pending',
        TaskStatus.completed => 'Completed',
        TaskStatus.cancelled => 'Cancelled',
      };

  static TaskStatus fromApi(String? value) => switch (value) {
        'Completed' => TaskStatus.completed,
        'Cancelled' => TaskStatus.cancelled,
        _ => TaskStatus.pending,
      };
}

/// What the employee is being asked to do.
enum TaskType {
  product,
  dose,
  other;

  static TaskType fromApi(String? value) => switch (value) {
        'product' => TaskType.product,
        'dose' => TaskType.dose,
        _ => TaskType.other,
      };
}

/// One task as it appears to the employee it is assigned to.
///
/// This is always *the signed-in employee's own* assignment: the tasks endpoint
/// scopes by the caller for an `Agriculture` user, so there is no other
/// employee's work in here and no employee id to carry around.
class TaskEntity extends Equatable {
  final int id;
  final int stationId;
  final String title;
  final String? description;
  final TaskType taskType;
  final TaskStatus status;
  final String? dueDate;
  final String? createdAt;
  final String? completedAt;

  /// The farm this task belongs to — shown on the all-farms list, where the
  /// same title can appear for several farms.
  final String? stationName;
  final String? createdByName;

  /// The employee's own note on their assignment.
  final String? note;

  /// Set only when the *station* called the task off — an employee who
  /// cancels it themselves leaves these null. See [isStoppedByStation].
  final String? cancelledAt;
  final String? cancelReason;
  final String? cancelledByName;

  /// Set only when the station marked the task done on the employee's
  /// behalf. See [isCompletedByStation].
  final String? completedByName;

  /// What the station wrote when marking it done for the employee.
  final String? completionNote;

  /// Who did the work, when the station logged the completion: the employee
  /// themselves, the station, or both. An employee's own completion keeps the
  /// defaults.
  final bool doneByEmployee;
  final bool doneByStation;

  /// What completing this task recorded on the farm — the material for a
  /// `product` task, the dose for a `dose` task. Null for an `other` task, a
  /// task never completed, or one completed before the server linked records
  /// to their task.
  final TaskProductRecord? recordedProduct;
  final TaskDoseRecord? recordedDose;

  const TaskEntity({
    required this.id,
    required this.stationId,
    required this.title,
    required this.taskType,
    required this.status,
    this.description,
    this.dueDate,
    this.createdAt,
    this.completedAt,
    this.stationName,
    this.createdByName,
    this.note,
    this.cancelledAt,
    this.cancelReason,
    this.cancelledByName,
    this.completedByName,
    this.completionNote,
    this.doneByEmployee = true,
    this.doneByStation = false,
    this.recordedProduct,
    this.recordedDose,
  });

  bool get isDone => status == TaskStatus.completed;

  /// The station stopped this task. The server refuses to complete or reopen
  /// it; the employee may only reply with a note.
  bool get isStoppedByStation =>
      status == TaskStatus.cancelled && cancelledAt != null;

  /// The station marked this done for the employee. The server refuses to
  /// reopen it; the employee may only add a note.
  bool get isCompletedByStation =>
      status == TaskStatus.completed && completedByName != null;

  bool get hasNote => (note ?? '').trim().isNotEmpty;

  TaskEntity copyWith({
    TaskStatus? status,
    String? note,
    bool clearNote = false,
    String? completedAt,
    bool clearCompletedAt = false,
    bool clearCancellation = false,
    TaskProductRecord? recordedProduct,
    TaskDoseRecord? recordedDose,
  }) =>
      TaskEntity(
        id: id,
        stationId: stationId,
        title: title,
        description: description,
        taskType: taskType,
        status: status ?? this.status,
        dueDate: dueDate,
        createdAt: createdAt,
        completedAt:
            clearCompletedAt ? null : (completedAt ?? this.completedAt),
        stationName: stationName,
        createdByName: createdByName,
        note: clearNote ? null : (note ?? this.note),
        cancelledAt: clearCancellation ? null : cancelledAt,
        cancelReason: clearCancellation ? null : cancelReason,
        cancelledByName: clearCancellation ? null : cancelledByName,
        completedByName: completedByName,
        completionNote: completionNote,
        doneByEmployee: doneByEmployee,
        doneByStation: doneByStation,
        recordedProduct: recordedProduct ?? this.recordedProduct,
        recordedDose: recordedDose ?? this.recordedDose,
      );

  @override
  List<Object?> get props => [
        id,
        stationId,
        title,
        taskType,
        status,
        dueDate,
        note,
        completedAt,
        cancelledAt,
        cancelReason,
        completedByName,
        completionNote,
        doneByEmployee,
        doneByStation,
        recordedProduct,
        recordedDose,
      ];
}

/// What completing a `product` task records on the farm — both what the
/// employee types into the form and what the server sends back afterwards.
class TaskProductRecord extends Equatable {
  final String materialType;
  final String brand;
  final String quantity;
  final String? quantityUnit;
  final DateTime? date;

  const TaskProductRecord({
    required this.materialType,
    required this.brand,
    required this.quantity,
    this.quantityUnit,
    this.date,
  });

  @override
  List<Object?> get props =>
      [materialType, brand, quantity, quantityUnit, date];
}

/// What completing a `dose` task records on the farm.
class TaskDoseRecord extends Equatable {
  final String quantity;
  final DateTime? date;

  const TaskDoseRecord({required this.quantity, this.date});

  @override
  List<Object?> get props => [quantity, date];
}
