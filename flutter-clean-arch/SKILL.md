---
name: flutter-clean-arch
description: >
  Scaffold complete Flutter features using Clean Architecture with BLoC, Freezed, and dartz Either
  error handling. Use this skill whenever the user asks to: create a Flutter feature, scaffold clean
  architecture layers, generate BLoC + Freezed boilerplate, set up a domain/data/presentation
  structure, add a new screen or module with proper separation of concerns, implement Clean Architecture,
  or mentions words like "feature", "usecase", "repository", "bloc", "entity", "datasource" in a
  Flutter context. Always use this skill even if the user just says "add auth to my flutter app",
  "I need a product listing feature", "implement Clean Architecture in Flutter", or "create BLoC
  structure" — these always benefit from proper clean architecture scaffolding.
---

# Flutter Clean Architecture Skill
## Stack: BLoC · Freezed · dartz · get_it

---

## Overview

This skill generates a **production-ready Flutter feature** across all Clean Architecture layers.
Given a feature name + entity fields, it outputs every file with correct imports, patterns, and DI wiring.

**Before generating any code**, read these reference files:
- `references/templates.md` — All code templates per layer (required)
- `references/pubspec-deps.md` — Required pubspec dependencies
- `references/error-handling.md` — Failure classes and Either patterns

---

## Step 1: Gather Feature Info

Ask the user if not already provided:

1. **Feature name** (e.g., `auth`, `product`, `user_profile`) — use `snake_case`
2. **Entity fields** (e.g., `id: String`, `name: String`, `price: double`) — for Freezed classes
3. **Use cases needed** — default is `Get{Feature}`. Ask if they need Create / Update / Delete too.
4. **API endpoint** (optional) — for datasource stub
5. **Local cache layer?** — adds a `{feature}_local_datasource.dart`

---

## Step 2: Plan & Present the File Tree

Show this tree **before generating**, substituting `{feature}`:

```
lib/
├── core/
│   ├── error/
│   │   ├── failures.dart           ← Failure sealed class (once per project)
│   │   └── exceptions.dart         ← Exception classes (once per project)
│   └── di/
│       └── injection_container.dart ← get_it registration (append per feature)
│
└── features/
    └── {feature}/
        ├── data/
        │   ├── datasources/
        │   │   ├── {feature}_remote_datasource.dart
        │   │   └── {feature}_local_datasource.dart   ← optional
        │   ├── models/
        │   │   └── {feature}_model.dart              ← Freezed + fromJson + toEntity()
        │   └── repositories/
        │       └── {feature}_repository_impl.dart
        │
        ├── domain/
        │   ├── entities/
        │   │   └── {feature}_entity.dart             ← Pure Freezed, no JSON
        │   ├── repositories/
        │   │   └── {feature}_repository.dart         ← Abstract contract
        │   └── usecases/
        │       ├── get_{feature}.dart
        │       ├── create_{feature}.dart              ← if requested
        │       ├── update_{feature}.dart              ← if requested
        │       └── delete_{feature}.dart              ← if requested
        │
        └── presentation/
            ├── bloc/
            │   ├── {feature}_bloc.dart
            │   ├── {feature}_event.dart              ← Freezed union
            │   └── {feature}_state.dart              ← Freezed union
            ├── pages/
            │   └── {feature}_page.dart
            └── widgets/
                └── (user adds widgets here)
```

---

## Step 3: Generate Files in Order

**Always generate in this dependency order** (top layers first):

| # | File | Notes |
|---|------|-------|
| 1 | `core/error/failures.dart` | Skip if already exists |
| 2 | `core/error/exceptions.dart` | Skip if already exists |
| 3 | `domain/entities/{feature}_entity.dart` | Pure Freezed, no Flutter/JSON imports |
| 4 | `domain/repositories/{feature}_repository.dart` | Abstract contract only |
| 5 | `domain/usecases/get_{feature}.dart` | One file per use case |
| 6 | `data/models/{feature}_model.dart` | Freezed + fromJson + toEntity() |
| 7 | `data/datasources/{feature}_remote_datasource.dart` | Abstract + Impl |
| 8 | `data/datasources/{feature}_local_datasource.dart` | Optional |
| 9 | `data/repositories/{feature}_repository_impl.dart` | Catches exceptions → Either |
| 10 | `presentation/bloc/{feature}_event.dart` | Freezed union per use case |
| 11 | `presentation/bloc/{feature}_state.dart` | initial/loading/loaded/error |
| 12 | `presentation/bloc/{feature}_bloc.dart` | Depends only on use cases |
| 13 | `presentation/pages/{feature}_page.dart` | BlocProvider + BlocBuilder |
| 14 | `core/di/injection_container.dart` | Append registrations |

---

## Step 4: Key Architecture Rules

Always enforce these — never break them:

| Layer | Rule |
|-------|------|
| **Entity** | Pure Freezed. No JSON annotations. No Flutter imports. |
| **Model** | Extends nothing; has `fromJson` + `toEntity()` extension. Mirrors entity fields. |
| **UseCase** | Single `call()` method. Returns `Future<Either<Failure, T>>`. Depends only on abstract repository. |
| **Repository contract** | In domain. Abstract only. No implementation details. |
| **Repository impl** | In data. Wraps datasource calls in try/catch. Maps exceptions → Failure. Returns Either. |
| **BLoC** | Depends only on use cases. Never imports datasource or repository impl directly. |
| **Events** | Freezed union. One factory per use case action. |
| **States** | Freezed union: `initial` / `loading` / `loaded({entity})` / `error(String message)`. |
| **Page** | Uses `BlocProvider` + `BlocBuilder` / `BlocConsumer`. Zero business logic. |

---

## Step 5: Multiple Use Cases

If more than one action is needed, generate one UseCase + one Event per action:

```
usecases/
├── get_{feature}.dart        → GetFeatureEvent
├── create_{feature}.dart     → CreateFeatureEvent
├── update_{feature}.dart     → UpdateFeatureEvent
└── delete_{feature}.dart     → DeleteFeatureEvent
```

Each BLoC event maps 1-to-1 with a use case. Register each handler with `on<EventType>(_handler)`.

---

## Step 6: Post-Generation Checklist

Always remind the user after generating:

```
✅ Add dependencies to pubspec.yaml (see references/pubspec-deps.md)
   flutter pub get

✅ Run code generation:
   dart run build_runner build --delete-conflicting-outputs

✅ Register your BLoC in injection_container.dart (uncomment the stubs)

✅ Call init() from injection_container.dart in main() before runApp()

✅ Wrap entry routes with BlocProvider or use getIt<{Feature}Bloc>()
```
