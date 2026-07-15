# StudyFlow AI — Feature Migration Guide

## Overview

This guide explains how to migrate a feature from the legacy `lib/screens/` structure to the new Feature-First Clean Architecture in `lib/features/`.

Migration is **incremental** — features are moved one at a time. The app remains fully functional at every step because legacy code coexists with new code via the `lib/legacy/index.dart` bridge.

---

## Migration Phases

| Phase | Features | Status |
|-------|----------|--------|
| Phase 0 | Architecture foundation (current) | ✅ Complete |
| Phase 1 | Splash + Onboarding | ⬜ Pending |
| Phase 2 | Authentication | ⬜ Pending |
| Phase 3 | Dashboard + Semesters | ⬜ Pending |
| Phase 4 | Notes + Subjects + Chapters | ⬜ Pending |
| Phase 5 | Schedules + Grades + Profile | ⬜ Pending |
| Phase 6 | AI Assistant (new feature) | ⬜ Future |

---

## Step-by-Step: Migrating One Feature

This example migrates the **Notes** feature. Substitute `notes` / `Note` / `NoteEntity` for any other feature.

---

### Step 1 — Define the Domain Entity

Create `lib/features/notes/domain/entities/note_entity.dart`:

```dart
/// Immutable business object for a Note.
/// No Flutter imports — pure Dart.
class NoteEntity {
  final String id;
  final String title;
  final String content;
  final String chapterId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.chapterId,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  NoteEntity copyWith({String? title, String? content}) {
    return NoteEntity(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      chapterId: chapterId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }
}
```

---

### Step 2 — Define the Repository Interface

Create `lib/features/notes/domain/repositories/note_repository.dart`:

```dart
import '../../../../core/utils/result.dart';
import '../entities/note_entity.dart';

/// Abstract contract for note data access.
/// Presentation and domain layers depend on this — never on the implementation.
abstract class NoteRepository {
  Future<Result<List<NoteEntity>>> getNotesByChapter(String chapterId);
  Future<Result<NoteEntity>> getNoteById(String id);
  Future<Result<NoteEntity>> createNote({
    required String title,
    required String content,
    required String chapterId,
  });
  Future<Result<NoteEntity>> updateNote(NoteEntity note);
  Future<Result<void>> deleteNote(String id);
}
```

---

### Step 3 — Create a Use Case

Create `lib/features/notes/domain/usecases/create_note_usecase.dart`:

```dart
import '../../../../core/utils/result.dart';
import '../entities/note_entity.dart';
import '../repositories/note_repository.dart';

/// Single-purpose use case: create a new note.
class CreateNoteUseCase {
  final NoteRepository _repository;
  const CreateNoteUseCase(this._repository);

  Future<Result<NoteEntity>> execute({
    required String title,
    required String content,
    required String chapterId,
  }) {
    return _repository.createNote(
      title: title,
      content: content,
      chapterId: chapterId,
    );
  }
}
```

---

### Step 4 — Create the Data Model

Create `lib/features/notes/data/models/note_model.dart`:

```dart
import '../../domain/entities/note_entity.dart';

/// Data Transfer Object for notes.
/// Handles JSON serialisation and mapping to/from NoteEntity.
class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.chapterId,
    required super.createdAt,
    required super.updatedAt,
    super.isDeleted,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      chapterId: json['chapterId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'content': content,
    'chapterId': chapterId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isDeleted': isDeleted,
  };
}
```

---

### Step 5 — Implement the Repository (Offline-First)

Create `lib/features/notes/data/repositories/note_repository_impl.dart`:

```dart
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';

/// Offline-first repository implementation.
/// Writes to Hive first, syncs to API when online.
class NoteRepositoryImpl implements NoteRepository {
  // Data sources injected via constructor (Phase 2: wire up to Riverpod)
  // final NoteLocalDataSource _local;
  // final NoteRemoteDataSource _remote;
  // final NetworkInfo _networkInfo;

  const NoteRepositoryImpl();

  @override
  Future<Result<List<NoteEntity>>> getNotesByChapter(
      String chapterId) async {
    // Phase 2: fetch from Hive, sync from API if online
    return Result.failure(
      const ServerFailure('Not yet implemented — Phase 2'),
    );
  }

  @override
  Future<Result<NoteEntity>> createNote({
    required String title,
    required String content,
    required String chapterId,
  }) async {
    // Phase 2: save to Hive, POST to API if online
    return Result.failure(
      const ServerFailure('Not yet implemented — Phase 2'),
    );
  }

  // ... other methods
  @override
  Future<Result<NoteEntity>> getNoteById(String id) async =>
      Result.failure(const ServerFailure('Not yet implemented'));

  @override
  Future<Result<NoteEntity>> updateNote(NoteEntity note) async =>
      Result.failure(const ServerFailure('Not yet implemented'));

  @override
  Future<Result<void>> deleteNote(String id) async =>
      Result.failure(const ServerFailure('Not yet implemented'));
}
```

---

### Step 6 — Create the Riverpod Provider

Create `lib/features/notes/presentation/providers/notes_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/note_entity.dart';
import '../../data/repositories/note_repository_impl.dart';

/// State class for the notes list
class NotesState {
  final List<NoteEntity> notes;
  final bool isLoading;
  final String? errorMessage;

  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  NotesState copyWith({
    List<NoteEntity>? notes,
    bool? isLoading,
    String? errorMessage,
  }) => NotesState(
    notes: notes ?? this.notes,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage,
  );
}

/// StateNotifier for notes
class NotesNotifier extends StateNotifier<NotesState> {
  NotesNotifier() : super(const NotesState());

  Future<void> loadNotes(String chapterId) async {
    state = state.copyWith(isLoading: true);
    // Phase 2: call use case
    state = state.copyWith(isLoading: false);
  }
}

/// Provider — wire up real repository in Phase 2
final notesNotifierProvider =
    StateNotifierProvider<NotesNotifier, NotesState>(
  (ref) => NotesNotifier(),
);
```

---

### Step 7 — Create the Screen

Create `lib/features/notes/presentation/screens/notes_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/widgets/layouts/app_scaffold.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../providers/notes_provider.dart';

class NotesScreen extends ConsumerStatefulWidget {
  final String chapterId;
  const NotesScreen({super.key, required this.chapterId});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  @override
  void initState() {
    super.initState();
    // Load notes when screen opens
    Future.microtask(() =>
      ref.read(notesNotifierProvider.notifier).loadNotes(widget.chapterId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notesNotifierProvider);

    return AppScaffold(
      title: 'Notes',
      body: state.isLoading
          ? const LoadingWidget()
          : state.notes.isEmpty
              ? const EmptyState(
                  message: 'No notes yet',
                  icon: Icons.note_outlined,
                )
              : ListView.builder(
                  itemCount: state.notes.length,
                  itemBuilder: (context, index) {
                    final note = state.notes[index];
                    return ListTile(title: Text(note.title));
                  },
                ),
    );
  }
}
```

---

### Step 8 — Add the Route

In `lib/config/routing/app_router.dart`, add:

```dart
import '../features/notes/presentation/screens/notes_screen.dart';

// Inside createRouter() routes list:
GoRoute(
  path: RoutePaths.noteDetail,  // '/notes/:id'
  name: 'noteDetail',
  builder: (context, state) => NotesScreen(
    chapterId: state.pathParameters['id']!,
  ),
),
```

---

### Step 9 — Remove Legacy Screen

1. Remove the screen export from `lib/legacy/index.dart`
2. Delete the old screen file from `lib/screens/`
3. Update any remaining imports across the codebase
4. Run `flutter analyze` to verify no broken imports

---

### Step 10 — Verify

```bash
cd frontend
flutter analyze
flutter test
```

Confirm the feature works:
- Opens correctly from navigation
- Shows loading state
- Shows empty state when no data
- Shows error state on failure
- Preserves data across hot reloads

---

## Rollback Procedure

If issues arise during migration:

1. Keep the legacy screen file — do NOT delete until fully tested
2. Revert the route in `app_router.dart` to point to the legacy screen
3. Re-add the export to `lib/legacy/index.dart`
4. Fix the issue in the new feature module
5. Re-attempt migration once fixed

---

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Feature folder | `snake_case` | `ai_assistant` |
| Dart files | `snake_case` | `note_entity.dart` |
| Classes | `PascalCase` | `NoteEntity` |
| Providers | `camelCase + Provider` | `notesNotifierProvider` |
| State classes | `PascalCase + State` | `NotesState` |
| Notifiers | `PascalCase + Notifier` | `NotesNotifier` |
| Use cases | `PascalCase + UseCase` | `CreateNoteUseCase` |
