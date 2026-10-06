# Error Handling Patterns — Flutter Clean Architecture

## Core Pattern: Exception → Failure → Either

```
DataSource      throws Exception
Repository      catches Exception → returns Left(Failure)
UseCase         returns Either<Failure, T>
BLoC            folds Either → emits State
UI              reacts to error state
```

---

## Exception vs Failure

| Type | Where | Purpose |
|------|-------|---------|
| `Exception` | Data layer only | Raw error from I/O (network, cache, parsing) |
| `Failure` | Domain + outward | Typed, user-friendly error abstraction |

**Rule**: Exceptions never cross the data/domain boundary. Repository impls catch all exceptions and return `Left(Failure)`.

---

## Repository Error Mapping

```dart
// Standard pattern for every repository method:
Future<Either<Failure, T>> someMethod() async {
  try {
    final result = await remoteDataSource.someMethod();
    return Right(result.toEntity());
  } on AuthException {
    return Left(AuthFailure());
  } on NetworkException {
    return Left(NetworkFailure());
  } on NotFoundException {
    return Left(NotFoundFailure());
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message));
  } catch (e) {
    // Catch-all — never swallow unknown errors silently
    return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
  }
}
```

---

## Using Either in BLoC

```dart
// fold() runs left function on Left, right function on Right
final result = await getProduct(event.id);

result.fold(
  (failure) => emit(ProductState.error(failure.message)),  // Left
  (product) => emit(ProductState.loaded(product)),          // Right
);
```

---

## Chaining Either Operations

```dart
// When you need to chain async Either operations, use flatMap/chain:
Future<Either<Failure, Output>> complexOperation() async {
  final step1 = await firstUseCase(input);
  
  return step1.fold(
    (failure) => Left(failure),
    (result) async {
      final step2 = await secondUseCase(result);
      return step2.fold(
        (failure) => Left(failure),
        (finalResult) => Right(finalResult),
      );
    },
  );
}
```

---

## BLoC State Emission Pattern

```dart
// Always emit loading before async work:
Future<void> _onFetch(FetchEvent event, Emitter<State> emit) async {
  emit(const State.loading());
  
  final result = await useCase(event.params);
  
  // fold is synchronous — no need for await
  result.fold(
    (failure) => emit(State.error(failure.message)),
    (data)    => emit(State.loaded(data)),
  );
}
```

---

## UI Error Handling with BlocConsumer

```dart
BlocConsumer<FeatureBloc, FeatureState>(
  // listener: side effects (Snackbar, navigation, dialogs)
  listener: (context, state) {
    state.whenOrNull(
      error: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      ),
      actionSuccess: (msg) => Navigator.of(context).pop(),
    );
  },
  // builder: UI rendering only
  builder: (context, state) => state.when(
    initial: () => const SizedBox.shrink(),
    loading: () => const CircularProgressIndicator(),
    loaded: (data) => DataWidget(data: data),
    listLoaded: (items) => ListView(...),
    actionSuccess: (_) => const SizedBox.shrink(),
    error: (msg) => ErrorWidget(message: msg),
  ),
)
```

---

## Custom Failure with Details

```dart
// For validation errors that carry field-level info:
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  const ValidationFailure({
    required String message,
    this.fieldErrors,
  }) : super(message: message);
}

// Usage:
return Left(ValidationFailure(
  message: 'Invalid input',
  fieldErrors: {'email': 'Invalid format', 'name': 'Required'},
));
```
