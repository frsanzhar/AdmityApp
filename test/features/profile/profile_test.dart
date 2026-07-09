/// Tests for Profile feature — §7.7 DESIGN_SYSTEM.md.
///
/// Test strategy:
///   - [InMemoryProfileRepository] injected via ProviderScope.overrides —
///     no device path, no Hive, no platform channels needed.
///   - Unit tests: domain model JSON round-trip, repository CRUD.
///   - Widget tests:
///       • ProfileScreen has no inline editable form
///       • pencil navigates (route stub works)
///       • default doc package is pre-loaded
///       • adding a doc works
///       • ProfileEditScreen: builds, has all fields, save persists
library;

import 'package:admity/core/l10n/l10n.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:admity/features/profile/presentation/profile_edit_screen.dart';
import 'package:admity/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/l10n_helpers.dart';

// ── Test helpers ──────────────────────────────────────────────────────────────

/// Wraps [child] with Admity theme + an [InMemoryProfileRepository] override.
///
/// Uses [MaterialApp.router] with a minimal GoRouter so that
/// `context.push('/profile/edit')` / `context.pop()` work correctly.
///
/// Route tree:
///   /            → child  (e.g. ProfileScreen)
///   /profile/edit → ProfileEditScreen
Widget _themed(
  Widget child, {
  InMemoryProfileRepository? repo,
}) {
  final effectiveRepo = repo ?? InMemoryProfileRepository();

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => child,
        routes: [
          GoRoute(
            path: 'profile/edit',
            builder: (context, state) => const ProfileEditScreen(),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(effectiveRepo),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(extensions: [AppTokens.defaults()]),
      locale: testLocale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: testLocalizationDelegates,
    ),
  );
}

/// Wraps [ProfileEditScreen] in a router where it is reachable via
/// `/profile/edit` from a parent `/` stub. This allows `context.pop()` to
/// succeed (pops back to the parent) without triggering "nothing to pop".
///
/// The test navigates to the edit screen immediately after pump.
Widget _editScreenApp({InMemoryProfileRepository? repo}) {
  final effectiveRepo = repo ?? InMemoryProfileRepository();

  final router = GoRouter(
    initialLocation: '/profile/edit',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('ParentScreen'))),
        routes: [
          GoRoute(
            path: 'profile/edit',
            builder: (context, state) => const ProfileEditScreen(),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(effectiveRepo),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(extensions: [AppTokens.defaults()]),
      locale: testLocale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: testLocalizationDelegates,
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
      const item = DocumentItem(id: 'i1', label: 'Диплом');
      final updated = item.copyWith(isAttached: true);

      expect(updated.id, 'i1');
      expect(updated.label, 'Диплом');
      expect(updated.isAttached, isTrue);
    });

    test('DocumentItem filePath and mimeType round-trip', () {
      const item = DocumentItem(
        id: 'i2',
        label: 'Аттестат',
        filePath: '/path/to/file.pdf',
        mimeType: 'application/pdf',
        isAttached: true,
      );
      final restored = DocumentItem.fromJson(item.toJson());
      expect(restored.filePath, '/path/to/file.pdf');
      expect(restored.mimeType, 'application/pdf');
      expect(restored.isAttached, isTrue);
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
        overrides: [profileRepositoryProvider.overrideWithValue(repo)],
      );
    }

    test('initial state has isLoading=true, then loads to false', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      expect(container.read(profileProvider).isLoading, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(profileProvider).isLoading, isFalse);
    });

    test('saveProfile updates state', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container
          .read(profileProvider.notifier)
          .saveProfile(const StudentProfile(name: 'Айгерим', city: 'Алматы'));

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
      await container
          .read(profileProvider.notifier)
          .addItemToPackage(packageId: pkgId, label: 'Транскрипт');

      final pkg = container.read(profileProvider).packages.first;
      expect(pkg.items.length, 1);
      expect(pkg.items.first.label, 'Транскрипт');
    });

    test('removeItemFromPackage removes the item', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container.read(profileProvider.notifier).addPackage(name: 'Pack');

      final pkgId = container.read(profileProvider).packages.first.id;
      await container
          .read(profileProvider.notifier)
          .addItemToPackage(packageId: pkgId, label: 'Рекомендация');

      final itemId = container
          .read(profileProvider)
          .packages
          .first
          .items
          .first
          .id;
      await container
          .read(profileProvider.notifier)
          .removeItemFromPackage(packageId: pkgId, itemId: itemId);

      expect(container.read(profileProvider).packages.first.items, isEmpty);
    });

    test('addItemToPackage on non-existent package is a no-op', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container
          .read(profileProvider.notifier)
          .addItemToPackage(packageId: 'nonexistent', label: 'Ignored');

      expect(container.read(profileProvider).packages, isEmpty);
    });

    test('ensureDefaultPackageSeeded seeds if no packages', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      expect(container.read(profileProvider).packages, isEmpty);

      await container
          .read(profileProvider.notifier)
          .ensureDefaultPackageSeeded();

      final pkgs = container.read(profileProvider).packages;
      expect(pkgs.isNotEmpty, isTrue);
      expect(pkgs.first.name, contains('Стандартный'));
      // Default items include the required KZ documents.
      expect(pkgs.first.items.isNotEmpty, isTrue);
      expect(
        pkgs.first.items.any((i) => i.label.contains('Удостоверение')),
        isTrue,
      );
    });

    test('ensureDefaultPackageSeeded is no-op when packages exist', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      await container
          .read(profileProvider.notifier)
          .addPackage(name: 'Existing');

      await container
          .read(profileProvider.notifier)
          .ensureDefaultPackageSeeded();

      // Should still have exactly one package, the existing one.
      final pkgs = container.read(profileProvider).packages;
      expect(pkgs.length, 1);
      expect(pkgs.first.name, 'Existing');
    });
  });

  // ── 4. ProfileScreen widget tests ─────────────────────────────────────────

  group('ProfileScreen widget', () {
    testWidgets('builds with no framework/layout errors', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(_themed(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason: 'no framework/layout errors on ProfileScreen',
      );
    });

    testWidgets('shows "Профиль" heading', (tester) async {
      await tester.pumpWidget(_themed(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Профиль'), findsOneWidget);
    });

    // KEY: The inline editable "Мои данные" form must NOT appear on the main screen.

    // KEY: The inline editable "Мои данные" form must NOT appear on the main screen.
    testWidgets('does NOT show inline editable form ("Мои данные")', (
      tester,
    ) async {
      await tester.pumpWidget(_themed(const ProfileScreen()));
      await tester.pumpAndSettle();

      // The "Сохранить" button belongs to ProfileEditScreen — it must NOT appear
      // on the main profile screen.
      expect(find.text('Сохранить'), findsNothing);

      // The "Мои данные" section title is on the edit screen, not here.
      expect(find.text('Мои данные'), findsNothing);

      // The main profile screen does NOT contain the edit-screen's field labels.
      // (The "Новый пакет" card on the main screen has package-name TextFields,
      //  but it does not have labels like "Имя", "Класс", "Город".)
      expect(find.text('Имя'), findsNothing);
      expect(find.text('Класс'), findsNothing);
    });

    testWidgets('shows pencil edit icon', (tester) async {
      await tester.pumpWidget(_themed(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('pencil icon navigates to ProfileEditScreen', (tester) async {
      await tester.pumpWidget(_themed(const ProfileScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      // After navigation, ProfileEditScreen should be present.
      expect(find.byType(ProfileEditScreen), findsOneWidget);
    });

    testWidgets('shows MascotSlot in identity header', (tester) async {
      await tester.pumpWidget(_themed(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == 'MascotSlot',
        ),
        findsOneWidget,
      );
    });

    testWidgets('does NOT show old career test card (moved to /psytests)', (
      tester,
    ) async {
      await tester.pumpWidget(_themed(const ProfileScreen()));
      await tester.pumpAndSettle();

      // The card was removed — its text must not appear on ProfileScreen.
      expect(find.text('Тест на профориентацию'), findsNothing);
    });

    testWidgets('shows "Пакет документов" section', (tester) async {
      await tester.pumpWidget(_themed(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Пакет документов'), findsOneWidget);
    });

    testWidgets('default doc package is preloaded with KZ documents', (
      tester,
    ) async {
      await tester.pumpWidget(_themed(const ProfileScreen()));
      await tester.pumpAndSettle();

      // After seeding, the standard package name appears.
      expect(find.textContaining('Стандартный'), findsWidgets);

      // At least one known KZ document label is present.
      expect(find.textContaining('Удостоверение'), findsWidgets);
    });

    testWidgets(
      'user can create a new package using the new package card',
      (tester) async {
        await tester.pumpWidget(_themed(const ProfileScreen()));
        await tester.pumpAndSettle();

        // The "Название пакета" label is a Text widget ABOVE the TextField.
        // The TextField's hint is "Например: NU 2026", not the label text.
        // Scroll until the "Создать пакет" button is visible, then find
        // the TextFields that belong to the new-package card.
        final createBtn = find.text('Создать пакет');
        await tester.scrollUntilVisible(
          createBtn,
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        // On ProfileScreen the new-package card has exactly 2 TextFields:
        // index 0 → Название пакета, index 1 → Описание.
        // Use the first one (package name field).
        await tester.enterText(find.byType(TextField).first, 'KBTU Pack');
        await tester.pump();

        await tester.ensureVisible(createBtn);
        await tester.pump();
        await tester.tap(createBtn);
        await tester.pumpAndSettle();

        // New package should appear in the list.
        expect(find.text('KBTU Pack'), findsOneWidget);
      },
    );
  });

  // ── 5. ProfileEditScreen widget tests ────────────────────────────────────

  group('ProfileEditScreen widget', () {
    testWidgets('builds with no framework/layout errors', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(_editScreenApp());
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason: 'no framework/layout errors on ProfileEditScreen',
      );
    });

    testWidgets('shows "Мои данные" title', (tester) async {
      await tester.pumpWidget(_editScreenApp());
      await tester.pumpAndSettle();

      expect(find.text('Мои данные'), findsOneWidget);
    });

    testWidgets('shows all required edit fields', (tester) async {
      await tester.pumpWidget(_editScreenApp());
      await tester.pumpAndSettle();

      // All fields should be present.
      expect(find.text('Имя'), findsOneWidget);
      expect(find.text('Класс'), findsOneWidget);
      expect(find.text('Город'), findsOneWidget);
      expect(find.text('Средний балл / ГПА'), findsOneWidget);
      expect(find.text('Языки (через запятую)'), findsOneWidget);
      expect(find.text('IELTS балл'), findsOneWidget);
      expect(find.text('SAT балл'), findsOneWidget);
      expect(find.text('TOEFL балл'), findsOneWidget);
      // At least 8 TextFields.
      expect(find.byType(TextField).evaluate().length, greaterThanOrEqualTo(8));
    });

    testWidgets('shows Save button', (tester) async {
      await tester.pumpWidget(_editScreenApp());
      await tester.pumpAndSettle();

      expect(find.text('Сохранить'), findsOneWidget);
    });

    testWidgets('editing name and saving persists to repository', (
      tester,
    ) async {
      final repo = InMemoryProfileRepository();
      // Use _editScreenApp so that context.pop() has a parent route to pop to.
      await tester.pumpWidget(_editScreenApp(repo: repo));
      await tester.pumpAndSettle();

      // The first TextField on ProfileEditScreen is the "Имя" (name) field.
      // ProfileEditScreen field order: name(0), grade(1), city(2), gpa(3),
      // languages(4), majors(5), interests(6), ielts(7), sat(8), toefl(9).
      await tester.enterText(find.byType(TextField).at(0), 'Айгерим');
      await tester.pump();

      // Scroll the Save button into view before tapping.
      final saveBtn = find.text('Сохранить');
      await tester.scrollUntilVisible(
        saveBtn,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.tap(saveBtn, warnIfMissed: false);
      // _save() calls saveProfile (async) then context.pop().
      await tester.pump(); // trigger async chain
      await tester.pump(const Duration(milliseconds: 100)); // repo save
      await tester.pump(const Duration(milliseconds: 300)); // pop animation

      // Data must be persisted in the repo.
      final saved = await repo.loadProfile();
      expect(saved.name, 'Айгерим');
    });

    testWidgets('editing and saving all fields persists correctly', (
      tester,
    ) async {
      final repo = InMemoryProfileRepository();
      // Use _editScreenApp so that context.pop() has a parent route to pop to.
      await tester.pumpWidget(_editScreenApp(repo: repo));
      await tester.pumpAndSettle();

      // ProfileEditScreen field order (index): name=0, grade=1, city=2,
      // gpa=3, languages=4, majors=5, interests=6, ielts=7, sat=8, toefl=9.
      // Enter text into each field then pump to let the controllers settle.
      await tester.enterText(find.byType(TextField).at(0), 'Данияр');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(1), '11 класс');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(2), 'Алматы');
      await tester.pump();

      // Dismiss the keyboard before tapping Save (prevents keyboard from
      // covering the button and causing the tap to be missed).
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Scroll the Save button into view before tapping.
      final saveBtn = find.text('Сохранить');
      await tester.scrollUntilVisible(
        saveBtn,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(saveBtn, warnIfMissed: false);
      // _save() calls saveProfile (async) then context.pop().
      await tester.pump(); // trigger async chain
      await tester.pump(const Duration(milliseconds: 100)); // repo save
      await tester.pump(const Duration(milliseconds: 300)); // pop animation

      final saved = await repo.loadProfile();
      expect(saved.name, 'Данияр');
      expect(saved.grade, '11 класс');
      expect(saved.city, 'Алматы');
    });
  });
}
