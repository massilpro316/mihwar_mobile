import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/usecases/create_activity.dart';
import '../../domain/usecases/get_activities.dart';

// ─── BLoC ────────────────────────────────────────────────────────────────────

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final GetActivities _getActivities;
  final CreateActivity _createActivity;

  ActivityBloc({
    required GetActivities getActivities,
    required CreateActivity createActivity,
  })  : _getActivities = getActivities,
        _createActivity = createActivity,
        super(const ActivityState()) {
    on<FetchActivitiesEvent>(_onFetchActivities);
    on<AddActivityEvent>(_onAddActivity);
  }

  Future<void> _onFetchActivities(
    FetchActivitiesEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, hasError: false));
    final result = await _getActivities(event.stationId);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: failure.message,
      )),
      (activities) =>
          emit(state.copyWith(isLoading: false, activities: activities)),
    );
  }

  Future<void> _onAddActivity(
    AddActivityEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    final result = await _createActivity(event.params);
    result.fold(
      (failure) {
        emit(state.copyWith(isSubmitting: false));
        if (event.context.mounted) {
          ScaffoldMessenger.of(event.context).showSnackBar(
            SnackBar(
                content: Text(failure.message), backgroundColor: Colors.red),
          );
        }
      },
      (employee) {
        emit(state.copyWith(
          isSubmitting: false,
          activities: [employee, ...state.activities],
        ));
        if (event.context.mounted) {
          ScaffoldMessenger.of(event.context).showSnackBar(
            const SnackBar(content: Text('Employee added successfully')),
          );
          Navigator.of(event.context).pop();
        }
      },
    );
  }
}

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();
  @override
  List<Object?> get props => [];
}

class FetchActivitiesEvent extends ActivityEvent {
  final int stationId;
  const FetchActivitiesEvent(this.stationId);
  @override
  List<Object?> get props => [stationId];
}

class AddActivityEvent extends ActivityEvent {
  final BuildContext context;
  final CreateActivityParams params;
  const AddActivityEvent({required this.context, required this.params});
}

// ─── State ───────────────────────────────────────────────────────────────────

class ActivityState extends Equatable {
  final List<ActivityEntity> activities;
  final bool isLoading;
  final bool isSubmitting;
  final bool hasError;
  final String errorMessage;

  const ActivityState({
    this.activities = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.hasError = false,
    this.errorMessage = '',
  });

  ActivityState copyWith({
    List<ActivityEntity>? activities,
    bool? isLoading,
    bool? isSubmitting,
    bool? hasError,
    String? errorMessage,
  }) =>
      ActivityState(
        activities: activities ?? this.activities,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        hasError: hasError ?? this.hasError,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props =>
      [activities, isLoading, isSubmitting, hasError, errorMessage];
}
