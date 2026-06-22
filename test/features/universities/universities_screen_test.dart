import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/opportunities/data/opportunity_seed.dart';
import 'package:admity/features/opportunities/domain/opportunity_models.dart';
import 'package:admity/features/opportunities/presentation/opportunities_providers.dart';
import 'package:admity/features/universities/presentation/universities_screen.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps the widget in a ProviderScope + MaterialApp (no router).
Widget _themed(Widget widget) {
  return ProviderScope(
    child: MaterialApp(
      theme: ThemeData(extensions: [AppTokens.defaults()]),
      home: Scaffold(body: widget),
    ),
  );
}

/// Wraps the widget with a GoRouter so navigation can be verified.
Widget _routerWrapped(Widget widget) {
  final router = GoRouter(
    initialLocation: '/universities',
    routes: [
      GoRoute(
        path: '/universities',
        builder: (context, state) => Scaffold(body: widget),
      ),
      GoRoute(
        path: '/opportunities/university/:id',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Text('UniDetail:${state.pathParameters['id']}'),
          ),
        ),
      ),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(extensions: [AppTokens.defaults()]),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Blank-screen guard ────────────────────────────────────────────────────

  group('UniversitiesScreen — blank-screen guard', () {
    testWidgets('builds with NO framework/layout errors', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason: 'no swallowed layout errors on UniversitiesScreen',
      );
    });
  });

  // ── Content assertions ────────────────────────────────────────────────────

  group('UniversitiesScreen — content', () {
    testWidgets('shows "Вузы" heading', (tester) async {
      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Вузы'), findsOneWidget);
    });

    testWidgets('shows MascotSlot in the header', (tester) async {
      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(MascotSlot), findsOneWidget);
    });

    testWidgets('shows filter chips: Город, Направление, Доступность', (
      tester,
    ) async {
      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Город'), findsOneWidget);
      expect(find.text('Направление'), findsOneWidget);
      expect(find.text('Доступность'), findsOneWidget);
    });

    testWidgets('lists all seed universities by default', (tester) async {
      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();

      // The list may be taller than the viewport, so scroll each university
      // into view before asserting it is present.
      for (final u in seedUniversities) {
        await tester.scrollUntilVisible(
          find.text(u.name),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(find.text(u.name), findsOneWidget);
      }
    });

    testWidgets('shows ProgressRing for acceptance-rate universities', (
      tester,
    ) async {
      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();

      // At least one university in seed has an acceptance rate — ring visible.
      expect(find.byType(ProgressRing), findsWidgets);
    });

    testWidgets('shows ENT threshold badge on cards', (tester) async {
      await tester.pumpWidget(_themed(const UniversitiesScreen()));
      await tester.pumpAndSettle();

      // НУ has entThreshold 110.
      expect(find.textContaining('ЕНТ ≥ 110'), findsOneWidget);
    });
  });

  // ── Filter behaviour ──────────────────────────────────────────────────────

  group('UniversitiesScreen — filters', () {
    testWidgets('filtering by city narrows the list', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const Scaffold(body: UniversitiesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Apply city filter programmatically.
      container.read(opportunityFilterProvider.notifier).setCity('Астана');
      await tester.pumpAndSettle();

      // Only Астана universities should be visible.
      final visible = seedUniversities
          .where((u) => u.city.toLowerCase().contains('астана'))
          .toList();
      final hidden = seedUniversities
          .where((u) => !u.city.toLowerCase().contains('астана'))
          .toList();

      for (final u in visible) {
        expect(find.text(u.name), findsOneWidget);
      }
      for (final u in hidden) {
        expect(find.text(u.name), findsNothing);
      }
    });

    testWidgets('clearing filter restores all universities', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const Scaffold(body: UniversitiesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(opportunityFilterProvider.notifier).setCity('Астана');
      await tester.pumpAndSettle();

      container.read(opportunityFilterProvider.notifier).clearAll();
      await tester.pumpAndSettle();

      // Scroll to verify every university is restored after clearing the filter.
      for (final u in seedUniversities) {
        await tester.scrollUntilVisible(
          find.text(u.name),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(find.text(u.name), findsOneWidget);
      }
    });

    testWidgets('shows empty state when no universities match filter', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const Scaffold(body: UniversitiesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container
          .read(opportunityFilterProvider.notifier)
          .setCity('НесуществующийГород999');
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Нет университетов'),
        findsOneWidget,
      );
    });

    testWidgets('active filter shows Сбросить chip', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [AppTokens.defaults()]),
            home: const Scaffold(body: UniversitiesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container
          .read(opportunityFilterProvider.notifier)
          .setAccessibility(Accessibility.hard);
      await tester.pumpAndSettle();

      expect(find.text('Сбросить'), findsOneWidget);
    });
  });

  // ── Navigation ────────────────────────────────────────────────────────────

  group('UniversitiesScreen — navigation', () {
    testWidgets(
      'tapping a university card pushes to /opportunities/university/:id',
      (
        tester,
      ) async {
        await tester.pumpWidget(_routerWrapped(const UniversitiesScreen()));
        await tester.pumpAndSettle();

        // Tap the first university in the seed list (НУ).
        await tester.tap(find.text('Назарбаев Университет'));
        await tester.pumpAndSettle();

        expect(find.textContaining('UniDetail:nu'), findsOneWidget);
      },
    );

    testWidgets('navigation works for second university too', (tester) async {
      await tester.pumpWidget(_routerWrapped(const UniversitiesScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('КазНУ им. аль-Фараби'));
      await tester.pumpAndSettle();

      expect(find.textContaining('UniDetail:kaznu'), findsOneWidget);
    });
  });
}
