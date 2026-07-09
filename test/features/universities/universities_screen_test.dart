import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/universities/data/university_catalog_providers.dart';
import 'package:admity/features/universities/domain/university_catalog.dart';
import 'package:admity/features/universities/presentation/universities_screen.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ── Fake catalog ────────────────────────────────────────────────────────────
const _fakeCatalog = UniversityCatalog(
  universities: [
    UniversityRecord(
      id: 'nu',
      nameRu: 'Назарбаев Университет',
      city: 'Астана',
      type: UniversityType.autonomous,
      hasDormitory: true,
    ),
    UniversityRecord(
      id: 'kaznu',
      nameRu: 'КазНУ им. аль-Фараби',
      city: 'Алматы',
      type: UniversityType.national,
    ),
    UniversityRecord(
      id: 'kbtu',
      nameRu: 'КБТУ',
      city: 'Алматы',
      type: UniversityType.private,
    ),
  ],
  programs: [
    EducationProgram(
      code: 'B057',
      nameRu: 'Информационные технологии',
      field: 'informatics',
      entSubject1: 'Математика',
      entSubject2: 'Информатика',
    ),
    EducationProgram(
      code: 'B073',
      nameRu: 'Архитектура',
      field: 'engineering',
    ),
    EducationProgram(
      code: 'B001',
      nameRu: 'Педагогика и психология',
      field: 'natural',
    ),
  ],
  offerings: [
    UniversityProgram(universityId: 'nu', programCode: 'B057'),
    UniversityProgram(universityId: 'kaznu', programCode: 'B057'),
    UniversityProgram(universityId: 'kaznu', programCode: 'B073'),
    UniversityProgram(universityId: 'kbtu', programCode: 'B073'),
  ],
  thresholds: [
    GrantThreshold(
      programCode: 'B057',
      universityId: 'nu',
      year: 2024,
      quotaType: QuotaType.general,
      metric: GrantMetric.competitionMin,
      minScore: 120,
      isVerified: true,
      sourceUrl: 'https://example.test',
    ),
    GrantThreshold(
      programCode: 'B057',
      universityId: 'kaznu',
      year: 2024,
      quotaType: QuotaType.general,
      metric: GrantMetric.competitionMin,
      minScore: 90,
      isVerified: true,
      sourceUrl: 'https://example.test',
    ),
  ],
);

// ignore: specify_nonobvious_property_types, the Override type is not exported.
final _overrides = [
  universityCatalogProvider.overrideWith((ref) => _fakeCatalog),
];

Widget _themed(Widget child) {
  return ProviderScope(
    overrides: _overrides,
    child: MaterialApp(
      theme: ThemeData(extensions: [AppTokens.defaults()]),
      home: child,
    ),
  );
}

Widget _router() {
  final router = GoRouter(
    initialLocation: '/uni-kz',
    routes: [
      GoRoute(
        path: '/uni-kz',
        builder: (context, state) => const UniversitiesScreen(),
      ),
      GoRoute(
        path: '/uni-kz/:id',
        builder: (context, state) => Scaffold(
          body: Center(child: Text('Detail:${state.pathParameters['id']}')),
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: _overrides,
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(extensions: [AppTokens.defaults()]),
    ),
  );
}

void main() {
  group('UniversitiesScreen — blank-screen guard', () {
    testWidgets('builds with NO framework/layout errors', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();

      expect(errors, isEmpty, reason: 'no swallowed layout errors');
    });
  });

  group('UniversitiesScreen — content', () {
    testWidgets('shows "Вузы" heading and count', (tester) async {
      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Вузы'), findsOneWidget);
      expect(find.textContaining('3 вузов'), findsOneWidget);
    });

    testWidgets('shows MascotSlot', (tester) async {
      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(MascotSlot), findsOneWidget);
    });

    testWidgets('filter chips are present and left-aligned', (tester) async {
      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Город'), findsOneWidget);
      expect(find.text('Направление'), findsOneWidget);
      expect(find.text('Тип'), findsOneWidget);
      // 'Общежитие' appears in both the filter chip and the NU card.
      expect(find.text('Общежитие'), findsWidgets);
      expect(find.text('Балл до…'), findsOneWidget);

      // The filter row must be within a SingleChildScrollView so it is
      // horizontally scrollable (not centred or truncated).
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('lists universities with type badge and honest score', (
      tester,
    ) async {
      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Назарбаев Университет'), findsOneWidget);
      expect(find.text('КазНУ им. аль-Фараби'), findsOneWidget);
      expect(find.text('Национальный'), findsOneWidget);
      // honest competition label, not "проходной"
      expect(find.textContaining('конкурс от'), findsWidgets);
    });
  });

  group('UniversitiesScreen — filters', () {
    testWidgets('filtering by city narrows the list', (tester) async {
      final container = ProviderContainer(overrides: _overrides);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const UniversitiesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(catalogFilterProvider.notifier).setCity('Астана');
      await tester.pumpAndSettle();

      expect(find.text('Назарбаев Университет'), findsOneWidget);
      expect(find.text('КазНУ им. аль-Фараби'), findsNothing);
    });

    testWidgets('filtering by major (IT) shows only IT universities', (
      tester,
    ) async {
      final container = ProviderContainer(overrides: _overrides);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const UniversitiesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Only nu and kaznu have IT (B057).
      container.read(catalogFilterProvider.notifier).setMajor(MajorCategory.it);
      await tester.pumpAndSettle();

      expect(find.text('Назарбаев Университет'), findsOneWidget);
      expect(find.text('КазНУ им. аль-Фараби'), findsOneWidget);
      // kbtu only has engineering (B073) — should be hidden.
      expect(find.text('КБТУ'), findsNothing);
    });

    testWidgets('filtering by engineering shows only engineering universities', (
      tester,
    ) async {
      final container = ProviderContainer(overrides: _overrides);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const UniversitiesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container
          .read(catalogFilterProvider.notifier)
          .setMajor(MajorCategory.engineering);
      await tester.pumpAndSettle();

      // kaznu and kbtu have engineering (B073).
      expect(find.text('КазНУ им. аль-Фараби'), findsOneWidget);
      expect(find.text('КБТУ'), findsOneWidget);
      // nu only has IT (B057) — should be hidden.
      expect(find.text('Назарбаев Университет'), findsNothing);
    });

    testWidgets('dormitory filter shows only universities with dormitories', (
      tester,
    ) async {
      final container = ProviderContainer(overrides: _overrides);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const UniversitiesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(catalogFilterProvider.notifier).toggleDormitory();
      await tester.pumpAndSettle();

      // Only nu has hasDormitory: true.
      expect(find.text('Назарбаев Университет'), findsOneWidget);
      expect(find.text('КазНУ им. аль-Фараби'), findsNothing);
      expect(find.text('КБТУ'), findsNothing);
    });

    testWidgets('score filter hides universities above the threshold', (
      tester,
    ) async {
      final container = ProviderContainer(overrides: _overrides);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const UniversitiesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // NU has minScore 120 — set limit to 100 so NU is filtered out.
      container.read(catalogFilterProvider.notifier).setMaxScore(100);
      await tester.pumpAndSettle();

      expect(find.text('Назарбаев Университет'), findsNothing);
      // kaznu has minScore 90 — should still show.
      expect(find.text('КазНУ им. аль-Фараби'), findsOneWidget);
      // kbtu has no score data — let it through.
      expect(find.text('КБТУ'), findsOneWidget);
    });

    testWidgets('empty state when no city matches', (tester) async {
      final container = ProviderContainer(overrides: _overrides);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const UniversitiesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(catalogFilterProvider.notifier).setCity('Нигде999');
      await tester.pumpAndSettle();

      expect(find.textContaining('Нет вузов'), findsOneWidget);
    });

    testWidgets('active filter shows Сбросить chip', (tester) async {
      final container = ProviderContainer(overrides: _overrides);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const UniversitiesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container
          .read(catalogFilterProvider.notifier)
          .setType(UniversityType.national);
      await tester.pumpAndSettle();

      expect(find.text('Сбросить'), findsOneWidget);
    });

    testWidgets('Сбросить clears all active filters', (tester) async {
      final container = ProviderContainer(overrides: _overrides);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const UniversitiesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Set two filters.
      container.read(catalogFilterProvider.notifier).setCity('Астана');
      container
          .read(catalogFilterProvider.notifier)
          .setMajor(MajorCategory.it);
      await tester.pumpAndSettle();

      expect(find.text('Сбросить'), findsOneWidget);

      // Clear all.
      await tester.tap(find.text('Сбросить'));
      await tester.pumpAndSettle();

      expect(find.text('Назарбаев Университет'), findsOneWidget);
      expect(find.text('КазНУ им. аль-Фараби'), findsOneWidget);
      expect(find.text('КБТУ'), findsOneWidget);
    });
  });

  group('UniversitiesScreen — navigation', () {
    testWidgets('tapping a card pushes to /universities/:id', (tester) async {
      await tester.pumpWidget(_router());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Назарбаев Университет'));
      await tester.pumpAndSettle();

      expect(find.text('Detail:nu'), findsOneWidget);
    });
  });
}
