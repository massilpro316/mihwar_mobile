# Flutter Clean Architecture — Code Templates

Replace `{Feature}` with PascalCase (e.g., `Product`)
Replace `{feature}` with snake_case (e.g., `product`)
Replace `{field}` placeholders with actual entity fields

---

## 1. DOMAIN LAYER

### `domain/entities/{feature}_entity.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{feature}_entity.freezed.dart';

@freezed
class {Feature}Entity with _${Feature}Entity {
  const factory {Feature}Entity({
    required String id,
    required String name,
    // ADD YOUR FIELDS HERE — no JSON annotations
  }) = _{Feature}Entity;
}
```

---

### `domain/repositories/{feature}_repository.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/{feature}_entity.dart';

abstract class {Feature}Repository {
  Future<Either<Failure, {Feature}Entity>> get{Feature}(String id);
  Future<Either<Failure, List<{Feature}Entity>>> getAll{Feature}s();
  Future<Either<Failure, {Feature}Entity>> create{Feature}({Feature}Entity entity);
  Future<Either<Failure, {Feature}Entity>> update{Feature}({Feature}Entity entity);
  Future<Either<Failure, void>> delete{Feature}(String id);
  // Keep only the methods your feature actually needs
}
```

---

### `domain/usecases/get_{feature}.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/{feature}_entity.dart';
import '../repositories/{feature}_repository.dart';

class Get{Feature} {
  final {Feature}Repository repository;
  Get{Feature}(this.repository);

  Future<Either<Failure, {Feature}Entity>> call(String id) =>
      repository.get{Feature}(id);
}
```

### `domain/usecases/get_all_{feature}s.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/{feature}_entity.dart';
import '../repositories/{feature}_repository.dart';

class GetAll{Feature}s {
  final {Feature}Repository repository;
  GetAll{Feature}s(this.repository);

  Future<Either<Failure, List<{Feature}Entity>>> call() =>
      repository.getAll{Feature}s();
}
```

### `domain/usecases/create_{feature}.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/{feature}_entity.dart';
import '../repositories/{feature}_repository.dart';

class Create{Feature} {
  final {Feature}Repository repository;
  Create{Feature}(this.repository);

  Future<Either<Failure, {Feature}Entity>> call({Feature}Entity entity) =>
      repository.create{Feature}(entity);
}
```

### `domain/usecases/update_{feature}.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/{feature}_entity.dart';
import '../repositories/{feature}_repository.dart';

class Update{Feature} {
  final {Feature}Repository repository;
  Update{Feature}(this.repository);

  Future<Either<Failure, {Feature}Entity>> call({Feature}Entity entity) =>
      repository.update{Feature}(entity);
}
```

### `domain/usecases/delete_{feature}.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/{feature}_repository.dart';

class Delete{Feature} {
  final {Feature}Repository repository;
  Delete{Feature}(this.repository);

  Future<Either<Failure, void>> call(String id) =>
      repository.delete{Feature}(id);
}
```

---

## 2. DATA LAYER

### `data/models/{feature}_model.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/{feature}_entity.dart';

part '{feature}_model.freezed.dart';
part '{feature}_model.g.dart';

@freezed
class {Feature}Model with _${Feature}Model {
  const factory {Feature}Model({
    required String id,
    required String name,
    // MIRROR entity fields here — add @JsonKey if API name differs
    // @JsonKey(name: 'full_name') required String name,
  }) = _{Feature}Model;

  factory {Feature}Model.fromJson(Map<String, dynamic> json) =>
      _${Feature}ModelFromJson(json);
}

extension {Feature}ModelMapper on {Feature}Model {
  {Feature}Entity toEntity() => {Feature}Entity(
        id: id,
        name: name,
        // MAP each field to entity
      );
}

extension {Feature}EntityMapper on {Feature}Entity {
  {Feature}Model toModel() => {Feature}Model(
        id: id,
        name: name,
        // MAP each field back to model (for create/update)
      );
}
```

---

### `data/datasources/{feature}_remote_datasource.dart`
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/{feature}_model.dart';

abstract class {Feature}RemoteDataSource {
  Future<{Feature}Model> get{Feature}(String id);
  Future<List<{Feature}Model>> getAll{Feature}s();
  Future<{Feature}Model> create{Feature}({Feature}Model model);
  Future<{Feature}Model> update{Feature}({Feature}Model model);
  Future<void> delete{Feature}(String id);
}

class {Feature}RemoteDataSourceImpl implements {Feature}RemoteDataSource {
  final http.Client client;
  static const _baseUrl = 'https://your-api.com';

  {Feature}RemoteDataSourceImpl({required this.client});

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  void _checkStatus(http.Response response) {
    if (response.statusCode == 401) throw AuthException();
    if (response.statusCode >= 400) {
      throw ServerException(message: 'Status: ${response.statusCode}');
    }
  }

  @override
  Future<{Feature}Model> get{Feature}(String id) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/{feature}/$id'),
      headers: _headers,
    );
    _checkStatus(response);
    return {Feature}Model.fromJson(json.decode(response.body));
  }

  @override
  Future<List<{Feature}Model>> getAll{Feature}s() async {
    final response = await client.get(
      Uri.parse('$_baseUrl/{feature}'),
      headers: _headers,
    );
    _checkStatus(response);
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((e) => {Feature}Model.fromJson(e)).toList();
  }

  @override
  Future<{Feature}Model> create{Feature}({Feature}Model model) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/{feature}'),
      headers: _headers,
      body: json.encode(model.toJson()),
    );
    _checkStatus(response);
    return {Feature}Model.fromJson(json.decode(response.body));
  }

  @override
  Future<{Feature}Model> update{Feature}({Feature}Model model) async {
    final response = await client.put(
      Uri.parse('$_baseUrl/{feature}/${model.id}'),
      headers: _headers,
      body: json.encode(model.toJson()),
    );
    _checkStatus(response);
    return {Feature}Model.fromJson(json.decode(response.body));
  }

  @override
  Future<void> delete{Feature}(String id) async {
    final response = await client.delete(
      Uri.parse('$_baseUrl/{feature}/$id'),
      headers: _headers,
    );
    _checkStatus(response);
  }
}
```

---

### `data/datasources/{feature}_local_datasource.dart` (optional)
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/{feature}_model.dart';

abstract class {Feature}LocalDataSource {
  Future<{Feature}Model> getCached{Feature}();
  Future<void> cache{Feature}({Feature}Model model);
  Future<void> clearCache();
}

class {Feature}LocalDataSourceImpl implements {Feature}LocalDataSource {
  final SharedPreferences prefs;
  static const _cacheKey = 'CACHED_{FEATURE}';

  {Feature}LocalDataSourceImpl({required this.prefs});

  @override
  Future<{Feature}Model> getCached{Feature}() async {
    final json = prefs.getString(_cacheKey);
    if (json == null) throw CacheException(message: 'No cached data');
    return {Feature}Model.fromJson(jsonDecode(json));
  }

  @override
  Future<void> cache{Feature}({Feature}Model model) async {
    await prefs.setString(_cacheKey, jsonEncode(model.toJson()));
  }

  @override
  Future<void> clearCache() async {
    await prefs.remove(_cacheKey);
  }
}
```

---

### `data/repositories/{feature}_repository_impl.dart`
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/{feature}_entity.dart';
import '../../domain/repositories/{feature}_repository.dart';
import '../datasources/{feature}_remote_datasource.dart';
// import '../datasources/{feature}_local_datasource.dart'; // uncomment if using cache

class {Feature}RepositoryImpl implements {Feature}Repository {
  final {Feature}RemoteDataSource remoteDataSource;
  // final {Feature}LocalDataSource localDataSource; // optional

  const {Feature}RepositoryImpl({
    required this.remoteDataSource,
    // required this.localDataSource,
  });

  @override
  Future<Either<Failure, {Feature}Entity>> get{Feature}(String id) async {
    try {
      final model = await remoteDataSource.get{Feature}(id);
      return Right(model.toEntity());
    } on AuthException {
      return Left(AuthFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<{Feature}Entity>>> getAll{Feature}s() async {
    try {
      final models = await remoteDataSource.getAll{Feature}s();
      return Right(models.map((m) => m.toEntity()).toList());
    } on AuthException {
      return Left(AuthFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, {Feature}Entity>> create{Feature}({Feature}Entity entity) async {
    try {
      final model = await remoteDataSource.create{Feature}(entity.toModel());
      return Right(model.toEntity());
    } on AuthException {
      return Left(AuthFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, {Feature}Entity>> update{Feature}({Feature}Entity entity) async {
    try {
      final model = await remoteDataSource.update{Feature}(entity.toModel());
      return Right(model.toEntity());
    } on AuthException {
      return Left(AuthFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete{Feature}(String id) async {
    try {
      await remoteDataSource.delete{Feature}(id);
      return const Right(null);
    } on AuthException {
      return Left(AuthFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
```

---

## 3. PRESENTATION LAYER

### `presentation/bloc/{feature}_event.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/{feature}_entity.dart';

part '{feature}_event.freezed.dart';

@freezed
class {Feature}Event with _${Feature}Event {
  // One event per use case:
  const factory {Feature}Event.get{Feature}(String id) = Get{Feature}Event;
  const factory {Feature}Event.getAll{Feature}s() = GetAll{Feature}sEvent;
  const factory {Feature}Event.create{Feature}({Feature}Entity entity) = Create{Feature}Event;
  const factory {Feature}Event.update{Feature}({Feature}Entity entity) = Update{Feature}Event;
  const factory {Feature}Event.delete{Feature}(String id) = Delete{Feature}Event;
  // Remove events you don't need
}
```

---

### `presentation/bloc/{feature}_state.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/{feature}_entity.dart';

part '{feature}_state.freezed.dart';

@freezed
class {Feature}State with _${Feature}State {
  const factory {Feature}State.initial()                              = {Feature}Initial;
  const factory {Feature}State.loading()                              = {Feature}Loading;
  const factory {Feature}State.loaded({Feature}Entity {feature})      = {Feature}Loaded;
  const factory {Feature}State.listLoaded(List<{Feature}Entity> items) = {Feature}ListLoaded;
  const factory {Feature}State.actionSuccess(String message)          = {Feature}ActionSuccess;
  const factory {Feature}State.error(String message)                  = {Feature}Error;
  // Keep only the states your UI actually needs
}
```

---

### `presentation/bloc/{feature}_bloc.dart`
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_{feature}.dart';
import '../../domain/usecases/get_all_{feature}s.dart';
import '../../domain/usecases/create_{feature}.dart';
import '../../domain/usecases/update_{feature}.dart';
import '../../domain/usecases/delete_{feature}.dart';
import '{feature}_event.dart';
import '{feature}_state.dart';

class {Feature}Bloc extends Bloc<{Feature}Event, {Feature}State> {
  final Get{Feature} get{Feature};
  final GetAll{Feature}s getAll{Feature}s;
  final Create{Feature} create{Feature};
  final Update{Feature} update{Feature};
  final Delete{Feature} delete{Feature};

  {Feature}Bloc({
    required this.get{Feature},
    required this.getAll{Feature}s,
    required this.create{Feature},
    required this.update{Feature},
    required this.delete{Feature},
  }) : super(const {Feature}State.initial()) {
    on<Get{Feature}Event>(_onGet{Feature});
    on<GetAll{Feature}sEvent>(_onGetAll{Feature}s);
    on<Create{Feature}Event>(_onCreate{Feature});
    on<Update{Feature}Event>(_onUpdate{Feature});
    on<Delete{Feature}Event>(_onDelete{Feature});
  }

  Future<void> _onGet{Feature}(
    Get{Feature}Event event,
    Emitter<{Feature}State> emit,
  ) async {
    emit(const {Feature}State.loading());
    final result = await get{Feature}(event.id);
    result.fold(
      (failure) => emit({Feature}State.error(failure.message)),
      ({feature}) => emit({Feature}State.loaded({feature})),
    );
  }

  Future<void> _onGetAll{Feature}s(
    GetAll{Feature}sEvent event,
    Emitter<{Feature}State> emit,
  ) async {
    emit(const {Feature}State.loading());
    final result = await getAll{Feature}s();
    result.fold(
      (failure) => emit({Feature}State.error(failure.message)),
      (items) => emit({Feature}State.listLoaded(items)),
    );
  }

  Future<void> _onCreate{Feature}(
    Create{Feature}Event event,
    Emitter<{Feature}State> emit,
  ) async {
    emit(const {Feature}State.loading());
    final result = await create{Feature}(event.entity);
    result.fold(
      (failure) => emit({Feature}State.error(failure.message)),
      (_) => emit(const {Feature}State.actionSuccess('{Feature} created successfully')),
    );
  }

  Future<void> _onUpdate{Feature}(
    Update{Feature}Event event,
    Emitter<{Feature}State> emit,
  ) async {
    emit(const {Feature}State.loading());
    final result = await update{Feature}(event.entity);
    result.fold(
      (failure) => emit({Feature}State.error(failure.message)),
      (_) => emit(const {Feature}State.actionSuccess('{Feature} updated successfully')),
    );
  }

  Future<void> _onDelete{Feature}(
    Delete{Feature}Event event,
    Emitter<{Feature}State> emit,
  ) async {
    emit(const {Feature}State.loading());
    final result = await delete{Feature}(event.id);
    result.fold(
      (failure) => emit({Feature}State.error(failure.message)),
      (_) => emit(const {Feature}State.actionSuccess('{Feature} deleted successfully')),
    );
  }
}
```

---

### `presentation/pages/{feature}_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/{feature}_bloc.dart';
import '../bloc/{feature}_event.dart';
import '../bloc/{feature}_state.dart';

class {Feature}Page extends StatelessWidget {
  final String id;
  const {Feature}Page({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<{Feature}Bloc>()
        ..add({Feature}Event.get{Feature}(id)),
      child: const _{Feature}View(),
    );
  }
}

class _{Feature}View extends StatelessWidget {
  const _{Feature}View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('{Feature}')),
      body: BlocConsumer<{Feature}Bloc, {Feature}State>(
        listener: (context, state) {
          state.whenOrNull(
            actionSuccess: (message) => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message))),
            error: (message) => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                )),
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: ({feature}) => Center(child: Text({feature}.id)),
            listLoaded: (items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) => ListTile(title: Text(items[i].id)),
            ),
            actionSuccess: (_) => const SizedBox.shrink(),
            error: (message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: $message'),
                  ElevatedButton(
                    onPressed: () => context
                        .read<{Feature}Bloc>()
                        .add({Feature}Event.get{Feature}('')),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

## 4. CORE FILES

### `core/error/failures.dart`
```dart
abstract class Failure {
  final String message;
  const Failure({this.message = 'An unexpected error occurred'});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error. Please try again.'});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection.'});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed.'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Local data error.'});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found.'});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message: message);
}
```

---

### `core/error/exceptions.dart`
```dart
class ServerException implements Exception {
  final String message;
  const ServerException({this.message = 'Server error'});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Network error'});
}

class AuthException implements Exception {
  final String message;
  const AuthException({this.message = 'Unauthorized'});
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache error'});
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException({this.message = 'Not found'});
}
```

---

### `core/di/injection_container.dart`
```dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// ── {Feature} imports ──────────────────────────────────────────────────────
// import '../../features/{feature}/data/datasources/{feature}_remote_datasource.dart';
// import '../../features/{feature}/data/repositories/{feature}_repository_impl.dart';
// import '../../features/{feature}/domain/repositories/{feature}_repository.dart';
// import '../../features/{feature}/domain/usecases/get_{feature}.dart';
// import '../../features/{feature}/domain/usecases/get_all_{feature}s.dart';
// import '../../features/{feature}/domain/usecases/create_{feature}.dart';
// import '../../features/{feature}/domain/usecases/update_{feature}.dart';
// import '../../features/{feature}/domain/usecases/delete_{feature}.dart';
// import '../../features/{feature}/presentation/bloc/{feature}_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // ─── External ─────────────────────────────────────────────────────────────
  getIt.registerLazySingleton(() => http.Client());

  // ─── {Feature} ────────────────────────────────────────────────────────────

  // BLoC — factory creates a new instance per page
  // getIt.registerFactory(
  //   () => {Feature}Bloc(
  //     get{Feature}: getIt(),
  //     getAll{Feature}s: getIt(),
  //     create{Feature}: getIt(),
  //     update{Feature}: getIt(),
  //     delete{Feature}: getIt(),
  //   ),
  // );

  // Use Cases
  // getIt.registerLazySingleton(() => Get{Feature}(getIt()));
  // getIt.registerLazySingleton(() => GetAll{Feature}s(getIt()));
  // getIt.registerLazySingleton(() => Create{Feature}(getIt()));
  // getIt.registerLazySingleton(() => Update{Feature}(getIt()));
  // getIt.registerLazySingleton(() => Delete{Feature}(getIt()));

  // Repository
  // getIt.registerLazySingleton<{Feature}Repository>(
  //   () => {Feature}RepositoryImpl(remoteDataSource: getIt()),
  // );

  // DataSource
  // getIt.registerLazySingleton<{Feature}RemoteDataSource>(
  //   () => {Feature}RemoteDataSourceImpl(client: getIt()),
  // );
}
```
