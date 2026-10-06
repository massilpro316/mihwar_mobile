import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/failure.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/get_tasks.dart';

// ─── BLoC ────────────────────────────────────────────────────────────────────

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks _getTasks;

  TaskBloc({required GetTasks getTasks})
      : _getTasks = getTasks,
        super(const TaskState()) {
    on<FetchTasksEvent>(_onFetchTasks);
    on<TaskSearchChangedEvent>(
      (event, emit) => emit(state.copyWith(query: event.query)),
    );
    on<TaskStatusFilterChangedEvent>(
      (event, emit) => emit(state.copyWith(
        statusFilter: event.status,
        clearStatusFilter: event.status == null,
      )),
    );
    on<TaskUpdatedEvent>(_onTaskUpdated);
  }

  /// A task changed on its own page — swap it in place, so the list is right
  /// the moment the employee comes back, without a reload.
  void _onTaskUpdated(TaskUpdatedEvent event, Emitter<TaskState> emit) {
    emit(state.copyWith(
      tasks: [
        for (final t in state.tasks) t.id == event.task.id ? event.task : t,
      ],
    ));
  }

  Future<void> _onFetchTasks(
    FetchTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      hasError: false,
      stationId: event.stationId,
      clearStationId: event.stationId == null,
    ));

    final result = await _getTasks(stationId: event.stationId);

    result.fold(
      // `failure.message` is developer-facing and can carry a Dio string, so it
      // never reaches the screen. The UI picks its own plain-language wording
      // from this flag instead.
      (failure) => emit(state.copyWith(
        isLoading: false,
        hasError: true,
        isOffline: failure is NetworkFailure,
      )),
      (tasks) => emit(state.copyWith(isLoading: false, tasks: tasks)),
    );
  }
}

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

/// Load the employee's tasks. A null [stationId] means "across every farm".
class FetchTasksEvent extends TaskEvent {
  final int? stationId;
  const FetchTasksEvent({this.stationId});

  @override
  List<Object?> get props => [stationId];
}

/// The words typed in the search box.
class TaskSearchChangedEvent extends TaskEvent {
  final String query;
  const TaskSearchChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Show only one status. Null means every status.
class TaskStatusFilterChangedEvent extends TaskEvent {
  final TaskStatus? status;
  const TaskStatusFilterChangedEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class TaskUpdatedEvent extends TaskEvent {
  final TaskEntity task;
  const TaskUpdatedEvent(this.task);

  @override
  List<Object?> get props => [task];
}

// ─── State ───────────────────────────────────────────────────────────────────

class TaskState extends Equatable {
  final List<TaskEntity> tasks;
  final bool isLoading;
  final bool hasError;

  /// The failure was "no connection" rather than a server problem, so the
  /// screen can tell the user which one to act on.
  final bool isOffline;

  /// Which farm the current list is scoped to, or null for all farms. Kept so a
  /// retry reloads the same scope the user was looking at.
  final int? stationId;

  final String query;

  /// Null shows every status.
  final TaskStatus? statusFilter;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.hasError = false,
    this.isOffline = false,
    this.stationId,
    this.query = '',
    this.statusFilter,
  });

  bool get isFiltering => query.trim().isNotEmpty || statusFilter != null;

  /// [sorted], narrowed by the search box and the status filter. The search
  /// looks at the title, description, farm name and note.
  List<TaskEntity> get visible {
    final q = query.trim().toLowerCase();
    return sorted.where((t) {
      if (statusFilter != null && t.status != statusFilter) return false;
      if (q.isEmpty) return true;
      return [t.title, t.description, t.stationName, t.note]
          .any((field) => (field ?? '').toLowerCase().contains(q));
    }).toList();
  }

  int countOf(TaskStatus status) =>
      tasks.where((t) => t.status == status).length;

  /// Tasks still to do first, then done, then cancelled — and within each
  /// group the soonest due date first. An undated task sorts last rather than
  /// jumping to the top.
  List<TaskEntity> get sorted {
    final copy = [...tasks];
    copy.sort((a, b) {
      if (a.status != b.status) return a.status.index - b.status.index;
      final da = a.dueDate;
      final db = b.dueDate;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });
    return copy;
  }

  int get pendingCount => countOf(TaskStatus.pending);

  TaskState copyWith({
    List<TaskEntity>? tasks,
    bool? isLoading,
    bool? hasError,
    bool? isOffline,
    int? stationId,
    bool clearStationId = false,
    String? query,
    TaskStatus? statusFilter,
    bool clearStatusFilter = false,
  }) =>
      TaskState(
        tasks: tasks ?? this.tasks,
        isLoading: isLoading ?? this.isLoading,
        hasError: hasError ?? this.hasError,
        isOffline: isOffline ?? this.isOffline,
        stationId: clearStationId ? null : (stationId ?? this.stationId),
        query: query ?? this.query,
        statusFilter:
            clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      );

  @override
  List<Object?> get props => [
        tasks,
        isLoading,
        hasError,
        isOffline,
        stationId,
        query,
        statusFilter,
      ];
}
