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
    ),
    UniversityRecord(
      id: 'kaznu',
      nameRu: 'КазНУ им. аль-Фараби',
      city: 'Алматы',
      type: UniversityType.national,
    ),
  ],
  programs: [
    EducationProgram(
      code: 'B057',
      nameRu: 'Информационные технологии',
      entSubject1: 'Математика',
      entSubject2: 'Информатика',
    ),
  ],
  offerings: [
    UniversityProgram(universityId: 'nu', programCode: 'B057'),
    UniversityProgram(universityId: 'kaznu', programCode: 'B057'),
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
    initialLocation: '/universities',
    routes: [
      GoRoute(
        path: '/universities',
        builder: (context, state) => const UniversitiesScreen(),
      ),
      GoRoute(
        path: '/universities/:id',
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
      expect(find.textContaining('2 вузов'), findsOneWidget);
    });

    testWidgets('shows MascotSlot', (tester) async {
      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(MascotSlot), findsOneWidget);
    });

    testWidgets('shows Город and Тип filter chips', (tester) async {
      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Город'), findsOneWidget);
      expect(find.text('Тип'), findsOneWidget);
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
