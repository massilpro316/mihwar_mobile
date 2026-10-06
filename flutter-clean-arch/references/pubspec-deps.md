# Required pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4

  # Immutable classes & sealed unions
  freezed_annotation: ^2.4.1

  # Functional error handling (Either, Option)
  dartz: ^0.10.1

  # Dependency Injection
  get_it: ^7.7.0

  # HTTP
  http: ^1.2.1

  # JSON serialization
  json_annotation: ^4.9.0

  # Optional: local cache
  # shared_preferences: ^2.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code generation
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
```

---

## Setup Commands

```bash
# 1. Install dependencies
flutter pub get

# 2. Run code generation (required after every Freezed class change)
dart run build_runner build --delete-conflicting-outputs

# 3. Watch mode during development (optional)
dart run build_runner watch --delete-conflicting-outputs
```

## When to Re-run build_runner

Re-run after any of these changes:
- Adding or modifying a `@freezed` class
- Adding or modifying a `@JsonSerializable` class
- Adding a new `.freezed.dart` or `.g.dart` part declaration
- Renaming fields on a Freezed class
