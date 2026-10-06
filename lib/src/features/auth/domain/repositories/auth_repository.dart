import 'package:mihwar/src/utils/utils.dart';
import 'package:mihwar/src/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get onAuthStateChanged;
  FutureEither<AppUser> login(
      {required String email, required String password});
  FutureEither<void> logout();
  FutureEither<AppUser?> checkAuthState();
}
