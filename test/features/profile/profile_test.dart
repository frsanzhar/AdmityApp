/// Tests for Profile feature — Phase 6.
///
/// Test strategy:
///   - [InMemoryProfileRepository] is injected via ProviderScope.overrides —
///     no device path, no Hive, no platform channels needed.
///   - Unit tests cover: domain model JSON round-trip, repository CRUD.
///   - Widget tests cover: screen builds without layout errors, CRUD flows.
library;

import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:admity/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Test helper ───────────────────────────────────────────────────────────────

/// Wraps [child] with Admity theme + an [InMemoryProfileRepository] override.
///
/// This is the key to avoiding a real device path: the production
/// [HiveProfileRepository] is overridden before any provider builds.
Widget _themed(Widget child, {InMemoryProfileRepository? repo}) {
  final effectiveRepo = repo ?? InMemoryProfileRepository();
  return ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(effectiveRepo),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [AppTokens.defaults()]),
      home: child,
    ),
  );
}

// ── 1. Domain model JSON round-trip ──────────────────────────────────────────

void main() {
  group('StudentProfile JSON round-trip', () {
    test('empty profile serialises and deserialises correctly', () {
      const profile = StudentProfile.empty;
      final json = profile.toJson();
      final restored = StudentProfile.fromJson(json);

      expect(restored.name, isNull);
      expect(restored.grade, isNull);
      expect(restored.city, isNull);
      expect(restored.gpaBand, isNull);
      expect(restored.targetUniversities, isEmpty);
      expect(restored.targetMajors, isEmpty);
      expect(restored.languages, isEmpty);
    });

    test('full profile round-trips without data loss', () {
      const profile = StudentProfile(
        name: 'Айгерим',
        grade: '11 класс',
        city: 'Алматы',
        gpaBand: '4.5–5.0',
        targetUniversities: ['NU', 'KBTU'],
        targetMajors: ['IT', 'Data Science'],
        languages: ['KZ', 'RU', 'EN'],
      );
      final restored = StudentProfile.fromJson(profile.toJson());

      expect(restored.name, 'Айгерим');
      expect(restored.grade, '11 класс');
      expect(restored.city, 'Алматы');
      expect(restored.gpaBand, '4.5–5.0');
      expect(restored.targetUniversities, ['NU', 'KBTU']);
      expect(restored.targetMajors, ['IT', 'Data Science']);
      expect(restored.languages, ['KZ', 'RU', 'EN']);
    });

    test('copyWith only updates specified fields', () {
      const profile = StudentProfile(name: 'Айгерим', grade: '11 класс');
      final updated = profile.copyWith(city: 'Астана');

      expect(updated.name, 'Айгерим');
      expect(updated.grade, '11 класс');
      expect(updated.city, 'Астана');
    });
  });

  group('ProfileNote JSON round-trip', () {
    test('note with updatedAt round-trips', () {
      final note = ProfileNote(
        id: 'note_1',
        text: 'Готовлюсь к IELTS',
        createdAt: DateTime(2026, 1, 15, 10),
        updatedAt: DateTime(2026, 1, 16, 12),
      );
      final restored = ProfileNote.fromJson(note.toJson());

      expect(restored.id, 'note_1');
      expect(restored.text, 'Готовлюсь к IELTS');
      expect(restored.updatedAt, isNotNull);
    });

    test('note without updatedAt round-trips', () {
      final note = ProfileNote(
        id: 'note_2',
        text: 'Без даты обновления',
        createdAt: DateTime(2026, 2),
      );
      final restored = ProfileNote.fromJson(note.toJson());

      expect(restored.id, 'note_2');
      expect(restored.updatedAt, isNull);
    });

    test('copyWith updates text and updatedAt', () {
      final note = ProfileNote(
        id: 'n1',
        text: 'Старый текст',
        createdAt: DateTime(2026),
      );
      final updated = note.copyWith(
        text: 'Новый текст',
        updatedAt: DateTime(2026, 3),
      );

      expect(updated.text, 'Новый текст');
      expect(updated.id, 'n1');
      expect(updated.updatedAt, isNotNull);
    });
  });

  group('DocumentPackage JSON round-trip', () {
    test('empty package round-trips', () {
      final pkg = DocumentPackage(
        id: 'pkg_1',
        name: 'NU 2026',
        createdAt: DateTime(2026),
      );
      final restored = DocumentPackage.fromJson(pkg.toJson());

      expect(restored.id, 'pkg_1');
      expect(restored.name, 'NU 2026');
      expect(restored.items, isEmpty);
    });

    test('package with items round-trips', () {
      final pkg = DocumentPackage(
        id: 'pkg_2',
        name: 'KBTU Pack',
        description: 'Для КБТУ',
        items: [
          const DocumentItem(id: 'item_1', label: 'Транскрипт'),
          const DocumentItem(
            id: 'item_2',
            label: 'Рекомендация',
            isAttached: true,
          ),
        ],
        createdAt: DateTime(2026, 3, 15),
      );
      final restored = DocumentPackage.fromJson(pkg.toJson());

      expect(restored.items.length, 2);
      expect(restored.items[0].label, 'Транскрипт');
      expect(restored.items[1].isAttached, isTrue);
    });

    test('DocumentItem copyWith preserves unmodified fields', () {
      const item = DocumentItem(
        id: 'i1',
        label: 'Диплом',
      );
      final updated = item.copyWith(isAttached: true);

      expect(updated.id, 'i1');
      expect(updated.label, 'Диплом');
      expect(updated.isAttached, isTrue);
    });
  });

  // ── 2. InMemoryProfileRepository unit tests ───────────────────────────────

  group('InMemoryProfileRepository', () {
    late InMemoryProfileRepository repo;

    setUp(() => repo = InMemoryProfileRepository());

    test('loadProfile returns empty on fresh repo', () async {
      final p = await repo.loadProfile();
      expect(p.name, isNull);
    });

    test('saveProfile then loadProfile returns saved data', () async {
      const profile = StudentProfile(name: 'Тест', city: 'Алматы');
      await repo.saveProfile(profile);
      final loaded = await repo.loadProfile();
      expect(loaded.name, 'Тест');
      expect(loaded.city, 'Алматы');
    });

    test('saveProfile overwrites previous data', () async {
      await repo.saveProfile(const StudentProfile(name: 'Старое'));
      await repo.saveProfile(const StudentProfile(name: 'Новое'));
      final loaded = await repo.loadProfile();
      expect(loaded.name, 'Новое');
    });

    test('loadNotes returns empty on fresh repo', () async {
      final notes = await repo.loadNotes();
      expect(notes, isEmpty);
    });

    test('saveNote then loadNotes includes the note', () async {
      final note = ProfileNote(
        id: 'n1',
        text: 'Заметка 1',
        createdAt: DateTime(2026, 4),
      );
      await repo.saveNote(note);
      final loaded = await repo.loadNotes();
      expect(loaded.length, 1);
      expect(loaded.first.text, 'Заметка 1');
    });

    test('deleteNote removes the note', () async {
      final note = ProfileNote(
        id: 'n_del',
        text: 'Удаляемая заметка',
        createdAt: DateTime(2026, 4),
      );
      await repo.saveNote(note);
      await repo.deleteNote('n_del');
      final loaded = await repo.loadNotes();
      expect(loaded, isEmpty);
    });

    test('deleteNote on non-existent id is a no-op', () async {
      await repo.deleteNote('non_existent');
      final loaded = await repo.loadNotes();
      expect(loaded, isEmpty);
    });

    test('loadPackages returns empty on fresh repo', () async {
      final pkgs = await repo.loadPackages();
      expect(pkgs, isEmpty);
    });

    test('savePackage then loadPackages includes the package', () async {
      final pkg = DocumentPackage(
        id: 'p1',
        name: 'NU Pack',
        createdAt: DateTime(2026, 5),
      );
      await repo.savePackage(pkg);
      final loaded = await repo.loadPackages();
      expect(loaded.length, 1);
      expect(loaded.first.name, 'NU Pack');
    });

    test('deletePackage removes the package', () async {
      final pkg = DocumentPackage(
        id: 'p_del',
        name: 'Удаляемый',
        createdAt: DateTime(2026, 5),
      );
      await repo.savePackage(pkg);
      await repo.deletePackage('p_del');
      final loaded = await repo.loadPackages();
      expect(loaded, isEmpty);
    });

    test('savePackage overwrites package with same id', () async {
      final original = DocumentPackage(
        id: 'p_upd',
        name: 'Старое имя',
        createdAt: DateTime(2026, 5),
      );
      final updated = original.copyWith(name: 'Новое имя');
      await repo.savePackage(original);
      await repo.savePackage(updated);
      final loaded = await repo.loadPackages();
      expect(loaded.length, 1);
      expect(loaded.first.name, 'Новое имя');
    });
  });

  // ── 3. ProfileNotifier integration ───────────────────────────────────────

  group('ProfileNotifier', () {
    ProviderContainer makeContainer() {
      final repo = InMemoryProfileRepository();
      return ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repo),
        ],
      );
    }

    test('initial state has isLoading=true, then loads to false', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      // Immediately after build: isLoading = true (before microtask fires)
      expect(container.read(profileProvider).isLoading, isTrue);

      // After microtask (the _load() call): isLoading = false
      await Future<void>.delayed(Duration.zero);

      expect(container.read(profileProvider).isLoading, isFalse);
    });

    test('saveProfile updates state', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero); // wait for initial load

      await container.read(profileProvider.notifier).saveProfile(
            const StudentProfile(name: 'Айгерим', city: 'Алматы'),
          );

      expect(container.read(profileProvider).profile.name, 'Айгерим');
      expect(container.read(profileProvider).profile.city, 'Алматы');
    });

    test('addNote appends to notes list', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container.read(profileProvider.notifier).addNote('Моя заметка');

      final notes = container.read(profileProvider).notes;
      expect(notes.length, 1);
      expect(notes.first.text, 'Моя заметка');
    });

    test('deleteNote removes from notes list', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container.read(profileProvider.notifier).addNote('Удаляемая');

      final noteId = container.read(profileProvider).notes.first.id;
      await container.read(profileProvider.notifier).deleteNote(noteId);

      expect(container.read(profileProvider).notes, isEmpty);
    });

    test('editNote updates text in notes list', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container.read(profileProvider.notifier).addNote('Оригинал');

      final noteId = container.read(profileProvider).notes.first.id;
      await container
          .read(profileProvider.notifier)
          .editNote(noteId, 'Обновлено');

      expect(container.read(profileProvider).notes.first.text, 'Обновлено');
    });

    test('addPackage creates a package', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container
          .read(profileProvider.notifier)
          .addPackage(name: 'NU 2026');

      expect(container.read(profileProvider).packages.length, 1);
      expect(container.read(profileProvider).packages.first.name, 'NU 2026');
    });

    test('deletePackage removes the package', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container
          .read(profileProvider.notifier)
          .addPackage(name: 'Удаляемый');

      final pkgId = container.read(profileProvider).packages.first.id;
      await container.read(profileProvider.notifier).deletePackage(pkgId);

      expect(container.read(profileProvider).packages, isEmpty);
    });

    test('addItemToPackage adds an item to the package', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container
          .read(profileProvider.notifier)
          .addPackage(name: 'Test Pack');

      final pkgId = container.read(profileProvider).packages.first.id;
      await container.read(profileProvider.notifier).addItemToPackage(
            packageId: pkgId,
            label: 'Транскрипт',
          );

      final pkg = container.read(profileProvider).packages.first;
      expect(pkg.items.length, 1);
      expect(pkg.items.first.label, 'Транскрипт');
    });

    test('removeItemFromPackage removes the item', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container
          .read(profileProvider.notifier)
          .addPackage(name: 'Pack');

      final pkgId = container.read(profileProvider).packages.first.id;
      await container.read(profileProvider.notifier).addItemToPackage(
            packageId: pkgId,
            label: 'Рекомендация',
          );

      final itemId =
          container.read(profileProvider).packages.first.items.first.id;
      await container.read(profileProvider.notifier).removeItemFromPackage(
            packageId: pkgId,
            itemId: itemId,
          );

      expect(container.read(profileProvider).packages.first.items, isEmpty);
    });

    test('addItemToPackage on non-existent package is a no-op', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container.read(profileProvider.notifier).addItemToPackage(
            packageId: 'nonexistent',
            label: 'Ignored',
          );

      expect(container.read(profileProvider).packages, isEmpty);
    });
  });

  // ── 4. ProfileScreen widget tests ─────────────────────────────────────────

  testWidgets('ProfileScreen builds with no framework/layout errors',
      (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_themed(const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(errors, isEmpty,
        reason: 'no framework/layout errors on ProfileScreen');
  });

  testWidgets('ProfileScreen shows header title', (tester) async {
    await tester.pumpWidget(_themed(const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Профиль'), findsOneWidget);
  });

  testWidgets('ProfileScreen shows three section titles', (tester) async {
    await tester.pumpWidget(_themed(const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Мои данные'), findsOneWidget);
    expect(find.text('Заметки о себе'), findsOneWidget);
    expect(find.text('Пакеты документов'), findsOneWidget);
  });

  testWidgets('ProfileScreen has Save button in self-data form', (tester) async {
    await tester.pumpWidget(_themed(const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Сохранить'), findsOneWidget);
  });

  testWidgets('ProfileScreen add-note button is present', (tester) async {
    await tester.pumpWidget(_themed(const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add_rounded), findsWidgets);
  });

  testWidgets('ProfileScreen shows "Новый пакет" form', (tester) async {
    await tester.pumpWidget(_themed(const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Новый пакет'), findsOneWidget);
    expect(find.text('Создать пакет'), findsOneWidget);
  });

  testWidgets('ProfileScreen shows MascotSlot in header', (tester) async {
    await tester.pumpWidget(_themed(const ProfileScreen()));
    await tester.pumpAndSettle();

    // MascotSlot widget is present in the header
    expect(
      find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == 'MascotSlot',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
      'ProfileScreen: typing a name and saving shows snack bar message',
      (tester) async {
    final repo = InMemoryProfileRepository();
    await tester.pumpWidget(_themed(const ProfileScreen(), repo: repo));
    await tester.pumpAndSettle();

    // Find the name field (first TextField on screen) and enter text.
    final nameFields = find.byType(TextField);
    await tester.enterText(nameFields.first, 'Айгерим');
    await tester.pump();

    // Ensure the Save button is visible and tap it.
    final saveBtn = find.text('Сохранить');
    await tester.ensureVisible(saveBtn);
    await tester.pump();
    await tester.tap(saveBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Данные сохранены'), findsOneWidget);
  });
}
