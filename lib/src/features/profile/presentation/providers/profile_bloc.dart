import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../../../routing/app_routes.dart';
import '../../../../services/auth_service.dart';

// ─── BLoC ────────────────────────────────────────────────────────────────────

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;

  ProfileBloc({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        super(const ProfileState()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, hasError: false));

    final result = await _getProfile();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: failure.message,
      )),
      (profile) => emit(state.copyWith(isLoading: false, profile: profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));

    final result = await _updateProfile(event.params);

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
      (profile) {
        emit(state.copyWith(isSubmitting: false, profile: profile));
        if (event.context.mounted) {
          ScaffoldMessenger.of(event.context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      },
    );
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await AuthService.instance.logout();
    if (event.context.mounted) {
      event.context.go(AppRoutes.login);
    }
  }
}

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class FetchProfileEvent extends ProfileEvent {
  const FetchProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final BuildContext context;
  final UpdateProfileParams params;
  const UpdateProfileEvent({required this.context, required this.params});
}

class SignOutEvent extends ProfileEvent {
  final BuildContext context;
  const SignOutEvent(this.context);
}

// ─── State ───────────────────────────────────────────────────────────────────

class ProfileState extends Equatable {
  final ProfileEntity? profile;
  final bool isLoading;
  final bool isSubmitting;
  final bool hasError;
  final String errorMessage;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSubmitting = false,
    this.hasError = false,
    this.errorMessage = '',
  });

  ProfileState copyWith({
    ProfileEntity? profile,
    bool? isLoading,
    bool? isSubmitting,
    bool? hasError,
    String? errorMessage,
  }) =>
      ProfileState(
        profile: profile ?? this.profile,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        hasError: hasError ?? this.hasError,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props =>
      [profile, isLoading, isSubmitting, hasError, errorMessage];
}
