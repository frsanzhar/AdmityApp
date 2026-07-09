/// Widget tests for the PsytestsRoadmapScreen.
///
/// Key assertions:
///   1. No layout / framework errors (blank-screen guard).
///   2. Progress header shows "0 из 12 тестов пройдено" initially.
///   3. Node N+1 is locked until node N is completed.
///   4. After submitting a result for test 1, test 2 becomes available.
library;

import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/psytests/application/psytests_notifier.dart';
import 'package:admity/features/psytests/data/psytests_repository.dart';
import 'package:admity/features/psytests/data/psytests_seed.dart';
import 'package:admity/features/psytests/domain/psytest_models.dart';
import 'package:admity/features/psytests/presentation/psytests_roadmap_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ── Test helpers ──────────────────────────────────────────────────────────────

/// Pumps [PsytestsRoadmapScreen] inside a minimal router+ProviderScope.
///
/// [repo] defaults to an empty [InMemoryPsytestsRepository].
Widget _app({InMemoryPsytestsRepository? repo}) {
  final effectiveRepo = repo ?? InMemoryPsytestsRepository();

  final router = GoRouter(
    initialLocation: '/psytests',
    routes: [
      GoRoute(
        path: '/psytests',
        builder: (context, state) => const PsytestsRoadmapScreen(),
        routes: [
          GoRoute(
            path: ':testId',
            builder: (context, state) =>
                const Scaffold(body: Text('TakingScreen')),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      psytestsRepositoryProvider.overrideWithValue(effectiveRepo),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(extensions: [AppTokens.defaults()]),
    ),
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  // ── 1. Blank-screen guard ──────────────────────────────────────────────────

  testWidgets('builds with no framework/layout errors', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(
      errors,
      isEmpty,
      reason: 'no framework/layout errors on PsytestsRoadmapScreen',
    );
  });

  // ── 2. Progress header ─────────────────────────────────────────────────────

  testWidgets('shows "0 из 12 тестов пройдено" initially', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('0 из 12 тестов пройдено'), findsOneWidget);
  });

  testWidgets('shows "Путь тестов" heading', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Путь тестов'), findsOneWidget);
  });

  // ── 3. Node locking — N+1 locked until N is done ──────────────────────────

  testWidgets('second test node is locked when first test not completed', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    // pump() once to trigger async _load() microtask.
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    // The roadmap renders LessonNode widgets.
    // Locked nodes display a lock icon; only 1 active node exists initially.
    // We verify by counting active (play) vs locked nodes:
    //   active   = 1  (first test)
    //   locked   = 11 (all others)
    //   done     = 0
    final playIcons = find.byIcon(Icons.play_arrow_rounded);
    final lockIcons = find.byIcon(Icons.lock_rounded);

    expect(playIcons, findsOneWidget, reason: 'Exactly 1 active node expected');
    expect(lockIcons, findsNWidgets(11), reason: '11 locked nodes expected');
  });

  testWidgets(
    'after completing test 1, test 2 becomes active and 10 remain locked',
    (tester) async {
      // Pre-populate the repo BEFORE pumping so the notifier loads the result
      // on first build (no need to repump).
      final repo = InMemoryPsytestsRepository();
      final def1 = psytestsDefs[0];
      await repo.saveResult(
        PsyTestResult(
          testId: def1.id,
          completedAt: DateTime(2026, 7, 8),
          scores: {'intro': 5, 'extro': 1, 'ambi': 2},
          topCategories: ['intro'],
        ),
      );

      await tester.pumpWidget(_app(repo: repo));
      // First pump: loading state.
      await tester.pump();
      // Second pump: async _load() completes.
      await tester.pump();
      await tester.pumpAndSettle();

      final checkIcons = find.byIcon(Icons.check_rounded);
      final playIcons = find.byIcon(Icons.play_arrow_rounded);
      final lockIcons = find.byIcon(Icons.lock_rounded);

      expect(checkIcons, findsOneWidget, reason: 'Test 1 should be done');
      expect(playIcons, findsOneWidget, reason: 'Test 2 should now be active');
      expect(lockIcons, findsNWidgets(10), reason: 'Tests 3–12 still locked');
    },
  );

  // ── 4. Progress counter updates ────────────────────────────────────────────

  testWidgets('progress text updates to "1 из 12" after one completion', (
    tester,
  ) async {
    // Pre-populate the repo so the notifier loads the completed result
    // on first build.
    final repo = InMemoryPsytestsRepository();
    final def1 = psytestsDefs[0];
    await repo.saveResult(
      PsyTestResult(
        testId: def1.id,
        completedAt: DateTime(2026, 7, 8),
        scores: {'intro': 5},
        topCategories: ['intro'],
      ),
    );

    await tester.pumpWidget(_app(repo: repo));
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('1 из 12 тестов пройдено'), findsOneWidget);
  });
}
