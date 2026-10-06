import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/farm_entity.dart';
import '../../domain/usecases/get_farms.dart';

// ─── BLoC ────────────────────────────────────────────────────────────────────

class FarmBloc extends Bloc<FarmEvent, FarmState> {
  final GetFarms _getFarms;

  FarmBloc({required GetFarms getFarms})
      : _getFarms = getFarms,
        super(const FarmState()) {
    on<FetchFarmsEvent>(_onFetchFarms);
  }

  Future<void> _onFetchFarms(
    FetchFarmsEvent event,
    Emitter<FarmState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, hasError: false));

    final result = await _getFarms();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: failure.message,
      )),
      (farms) => emit(state.copyWith(isLoading: false, farms: farms)),
    );
  }
}

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class FarmEvent extends Equatable {
  const FarmEvent();
  @override
  List<Object?> get props => [];
}

class FetchFarmsEvent extends FarmEvent {
  const FetchFarmsEvent();
}

// ─── State ───────────────────────────────────────────────────────────────────

class FarmState extends Equatable {
  final List<FarmEntity> farms;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;

  const FarmState({
    this.farms = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
  });

  FarmState copyWith({
    List<FarmEntity>? farms,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) =>
      FarmState(
        farms: farms ?? this.farms,
        isLoading: isLoading ?? this.isLoading,
        hasError: hasError ?? this.hasError,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [farms, isLoading, hasError, errorMessage];
}
