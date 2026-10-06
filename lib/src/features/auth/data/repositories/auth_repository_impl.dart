import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import 'package:mihwar/src/features/auth/domain/entities/user.dart';
import 'package:mihwar/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService = AuthService.instance;

  @override
  Stream<AppUser?> get onAuthStateChanged {
    return _authService.authStateChanges.map((userData) {
      if (userData == null) return null;
      return AppUser(
        id: userData['id']?.toString() ?? '',
        email: userData['email'] ?? '',
        name: userData['name'],
        photoUrl: userData['photoUrl'],
        role: userData['role'],
        phoneNumber: userData['phone_number'],
        grade: userData['grade'],
      );
    });
  }

  @override
  FutureEither<AppUser> login({
    required String email,
    required String password,
  }) async {
    final result = await _authService.login(email: email, password: password);
    return result.flatMap((userData) {
      if (userData == null) {
        return left(const ServerFailure('Login failed: User record not found'));
      }
      final data = userData['user'] ?? userData;
      return right(AppUser(
        id: data['id'].toString(),
        email: data['email'] ?? email,
        name: data['name'],
        role: data['role'],
        phoneNumber: data['phone_number'],
        grade: data['grade'],
      ));
    });
  }

  @override
  FutureEither<void> logout() => _authService.logout();

  @override
  FutureEither<AppUser?> checkAuthState() async {
    final result = await _authService.getCurrentUser();
    return result.map((userData) {
      if (userData == null) return null;
      final data = (userData['user'] ?? userData) as Map<String, dynamic>;
      return AppUser(
        id: data['id']?.toString() ?? '',
        email: data['email'] ?? '',
        name: data['name'],
        role: data['role'],
        phoneNumber: data['phone_number'],
        grade: data['grade'],
      );
    });
  }
}
