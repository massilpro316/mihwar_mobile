import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';
import 'package:mihwar/src/features/auth/domain/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(const AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result =
        await _repository.login(email: event.email, password: event.password);
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        if (event.context.mounted) {
          showToast(event.context, message: failure.message, status: 'error');
        }
      },
      (_) {
        emit(state.copyWith(isLoading: false));
        if (event.context.mounted) {
          event.context.go(AppRoutes.home);
        }
      },
    );
  }
}

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final BuildContext context;
  final String email;
  final String password;
  const LoginRequested(
      {required this.context, required this.email, required this.password});
}

class AuthState extends Equatable {
  final bool isLoading;
  const AuthState({required this.isLoading});
  const AuthState.initial() : isLoading = false;
  AuthState copyWith({bool? isLoading}) =>
      AuthState(isLoading: isLoading ?? this.isLoading);
  @override
  List<Object?> get props => [isLoading];
}
