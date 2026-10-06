import '../../imports/imports.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/providers/session_bloc.dart';
import '../../features/auth/presentation/providers/auth_bloc.dart';

class StateWrapper extends StatelessWidget {
  final Widget child;

  const StateWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepositoryImpl();
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionBloc>(
          create: (_) => SessionBloc(repository: authRepo),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(repository: authRepo),
        ),
      ],
      child: child,
    );
  }
}
