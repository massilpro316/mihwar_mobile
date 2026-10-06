import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import '../utils/utils.dart';
import 'dio_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _tokenKey = 'auth_token';
  final _storage = const FlutterSecureStorage();
  final StreamController<Map<String, dynamic>?> _authStateController =
      StreamController<Map<String, dynamic>?>.broadcast();

  Stream<Map<String, dynamic>?> get authStateChanges =>
      _authStateController.stream;

  FutureEither<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final result = await DioService.instance.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    Failure? failure;
    dynamic response;
    result.fold((f) => failure = f, (r) => response = r);
    if (failure != null) return left(failure!);

    final data = (response.data as Map<String, dynamic>?) ?? {};
    final token = data['token'] as String?;
    if (token != null) await _storage.write(key: _tokenKey, value: token);

    final userData = (data['user'] ?? data) as Map<String, dynamic>;
    _authStateController.add(userData);
    return right(userData);
  }

  FutureEither<void> logout() async {
    await _storage.delete(key: _tokenKey);
    _authStateController.add(null);
    return right(null);
  }

  FutureEither<Map<String, dynamic>?> getCurrentUser() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return right(null);

    // Validate saved token with backend
    final result = await DioService.instance.get('/api/auth/me');
    return result.fold(
      (failure) async {
        // Saved token is expired or invalid — remove it and return null to prompt login
        await _storage.delete(key: _tokenKey);
        return right(null);
      },
      (response) {
        final data = response.data as Map<String, dynamic>?;
        final userData = (data?['user'] ?? data) as Map<String, dynamic>?;
        return right(userData ?? {'authenticated': true});
      },
    );
  }

  void dispose() {
    _authStateController.close();
  }
}
