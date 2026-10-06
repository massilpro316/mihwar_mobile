import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import 'package:mihwar/src/features/auth/presentation/providers/session_bloc.dart';


class SessionListenerWrapper extends StatelessWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listenWhen: (prev, next) => prev.status != next.status,
      listener: (context, state) {
        if (state.status != SessionStatus.unknown) {
          FlutterNativeSplash.remove();
          // Use appRouter.go() directly instead of context.go().
          // The BlocListener callback fires during startup before the
          // MaterialApp.router is fully mounted, so GoRouter is not yet
          // reachable via the listener's BuildContext. Calling go() on the
          // global GoRouter instance bypasses the context lookup entirely.
          if (state.status == SessionStatus.authenticated) {
            appRouter.go(AppRoutes.home);
          } else if (state.status == SessionStatus.unauthenticated) {
            appRouter.go(AppRoutes.login);
          }
        }
      },
      child: child,
    );
  }
}
