import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/failure.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/save_task_note.dart';
import '../../domain/usecases/update_task_status.dart';

// ─── BLoC ────────────────────────────────────────────────────────────────────

/// One task on its own page, and the actions the employee can take on it:
/// complete, cancel (refuse), reopen, and write a note.
class TaskDetailBloc extends Bloc<TaskDetailEvent, TaskDetailState> {
  final UpdateTaskStatus _updateTaskStatus;
  final SaveTaskNote _saveTaskNote;

  TaskDetailBloc({
    required TaskEntity task,
    required UpdateTaskStatus updateTaskStatus,
    required SaveTaskNote saveTaskNote,
  })  : _updateTaskStatus = updateTaskStatus,
        _saveTaskNote = saveTaskNote,
        super(TaskDetailState(task: task)) {
    on<ChangeTaskStatusEvent>(_onChangeStatus);
    on<SaveTaskNoteEvent>(_onSaveNote);
  }

  Future<void> _onChangeStatus(
    ChangeTaskStatusEvent event,
    Emitter<TaskDetailState> emit,
  ) async {
    // A second tap while the first is on its way would send the task twice —
    // and for a `product` task, write the material to the farm twice.
    if (state.isSubmitting) return;
    emit(state.copyWith(submission: TaskSubmission.submitting));

    final result = await _updateTaskStatus(
      task: state.task,
      status: event.status,
      note: event.note,
      product: event.product,
      dose: event.dose,
    );

    result.fold(
      (failure) => emit(_failed(failure)),
      (task) => emit(state.copyWith(
        task: task,
        submission: TaskSubmission.success,
        lastAction: switch (event.status) {
          TaskStatus.completed => TaskAction.completed,
          TaskStatus.cancelled => TaskAction.cancelled,
          TaskStatus.pending => TaskAction.reopened,
        },
        changed: true,
      )),
    );
  }

  Future<void> _onSaveNote(
    SaveTaskNoteEvent event,
    Emitter<TaskDetailState> emit,
  ) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(submission: TaskSubmission.submitting));

    final result = await _saveTaskNote(task: state.task, note: event.note);

    result.fold(
      (failure) => emit(_failed(failure)),
      (task) => emit(state.copyWith(
        task: task,
        submission: TaskSubmission.success,
        lastAction: TaskAction.noteSaved,
        changed: true,
      )),
    );
  }

  TaskDetailState _failed(Failure failure) => state.copyWith(
        submission: TaskSubmission.failure,
        isOffline: failure is NetworkFailure,
        // The server's own wording for a refused request is plain Arabic
        // meant for the employee ("please enter the dose quantity…", "the
        // station cancelled this task…"). Anything else is left null, and the
        // screen shows its own translated message instead.
        serverMessage: _plainServerMessage(failure),
      );

  static String? _plainServerMessage(Failure failure) {
    if (failure is! ServerFailure) return null;
    final code = _statusCode(failure.error);
    if (code == 400 || code == 409) return failure.message;
    return null;
  }

  static int? _statusCode(dynamic error) {
    try {
      return error?.response?.statusCode as int?;
    } catch (_) {
      return null;
    }
  }
}

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class TaskDetailEvent extends Equatable {
  const TaskDetailEvent();
  @override
  List<Object?> get props => [];
}

class ChangeTaskStatusEvent extends TaskDetailEvent {
  final TaskStatus status;
  final String? note;
  final TaskProductRecord? product;
  final TaskDoseRecord? dose;

  const ChangeTaskStatusEvent({
    required this.status,
    this.note,
    this.product,
    this.dose,
  });

  @override
  List<Object?> get props => [status, note, product, dose];
}

class SaveTaskNoteEvent extends TaskDetailEvent {
  final String note;
  const SaveTaskNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

// ─── State ───────────────────────────────────────────────────────────────────

enum TaskSubmission { idle, submitting, success, failure }

enum TaskAction { completed, cancelled, reopened, noteSaved }

class TaskDetailState extends Equatable {
  final TaskEntity task;
  final TaskSubmission submission;
  final TaskAction? lastAction;

  /// Something was saved on this page, so the list behind it must be updated
  /// when the employee goes back.
  final bool changed;

  final bool isOffline;

  /// Set only for a refusal the server explained in words meant for the
  /// employee. See `TaskDetailBloc._failed`.
  final String? serverMessage;

  const TaskDetailState({
    required this.task,
    this.submission = TaskSubmission.idle,
    this.lastAction,
    this.changed = false,
    this.isOffline = false,
    this.serverMessage,
  });

  bool get isSubmitting => submission == TaskSubmission.submitting;

  TaskDetailState copyWith({
    TaskEntity? task,
    TaskSubmission? submission,
    TaskAction? lastAction,
    bool? changed,
    bool? isOffline,
    String? serverMessage,
  }) =>
      TaskDetailState(
        task: task ?? this.task,
        submission: submission ?? this.submission,
        lastAction: lastAction ?? this.lastAction,
        changed: changed ?? this.changed,
        // Both describe the last failure only; a new submission clears them.
        isOffline: isOffline ?? false,
        serverMessage: serverMessage,
      );

  @override
  List<Object?> get props =>
      [task, submission, lastAction, changed, isOffline, serverMessage];
}
