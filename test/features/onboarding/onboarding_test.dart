/// Widget tests for OnboardingScreen.
library;

import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/onboarding/presentation/onboarding_screen.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Wraps [OnboardingScreen] (or any child) in a [MaterialApp.router] backed by
/// a minimal [GoRouter] so that `context.go('/home')` inside [OnboardingScreen]
/// does not throw "No GoRouter found in context".
Widget _themed(Widget child, {InMemoryProfileRepository? repo}) {
  final effectiveRepo = repo ?? InMemoryProfileRepository();

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => child,
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('HomeScreen'))),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('OnboardingScreen'))),
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
    ),
  );
}

void main() {
  testWidgets('OnboardingScreen builds without layout errors', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    expect(
      errors,
      isEmpty,
      reason: 'no framework/layout errors on OnboardingScreen',
    );
  });

  testWidgets('First step shows role selection cards', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // Step 0 is the role step — it shows role choice cards.
    expect(find.text('Я учусь'), findsOneWidget);
  });

  testWidgets('Progress bar is present on step 0', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // The segmented progress bar uses AnimatedContainers in a Row.
    // We verify it renders by checking for at least one AnimatedContainer.
    expect(find.byType(AnimatedContainer), findsWidgets);
  });

  testWidgets('Далее advances after role is selected', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // Step 0 requires role selection before Далее is enabled.
    // Tap the role card first.
    await tester.tap(find.text('Я учусь'));
    await tester.pumpAndSettle();

    // Now tap Далее to advance to step 1.
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();

    // Step 1 shows the mascot greeting.
    expect(find.text('Привет! Я — Ералы,'), findsOneWidget);
  });

  testWidgets('Back button absent on step 0', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // Step 0: no back button, role cards visible.
    expect(find.text('Я учусь'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
  });

  testWidgets('Back button present after step 1', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // Select role then advance to step 1.
    await tester.tap(find.text('Я учусь'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();

    // Back arrow should now be visible.
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('Motivation step shows 4 option cards', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // Navigate to step 2 (motivation): select role → Далее → Далее.
    await tester.tap(find.text('Я учусь'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Далее'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Далее'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 50));

    // Motivation step shows the heading and all 4 option labels.
    expect(find.text('Что тебя мотивирует?'), findsOneWidget);
    expect(find.text('Высокая цель'), findsOneWidget);
    expect(find.text('Новые знания'), findsOneWidget);
    expect(find.text('Карьера'), findsOneWidget);
    expect(find.text('Интерес'), findsOneWidget);
  });

  testWidgets(
    'onboardingComplete saved on finish via Начать',
    (tester) async {
      final repo = InMemoryProfileRepository();
      await tester.pumpWidget(_themed(const OnboardingScreen(), repo: repo));
      await tester.pumpAndSettle();

      // Helper: pump through an AnimatedSwitcher transition.
      Future<void> pump() async {
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Step 0: role selection required before Далее is enabled.
      await tester.tap(find.text('Я учусь'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Далее'));
      await pump();

      // Step 1: mascot greeting — no selection required, Далее works.
      await tester.tap(find.text('Далее'));
      await pump();

      // Step 2: motivation — selection required.
      await tester.tap(find.text('Высокая цель'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Далее'));
      await pump();

      // Step 3: sound preference — selection required.
      await tester.tap(find.text('Мелодичный'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Далее'));
      await pump();

      // Step 4: age — no selection required (text field, defaults canAdvance=true).
      await tester.tap(find.text('Далее'));
      await pump();

      // Step 5: subject — selection required.
      await tester.tap(find.text('Математика'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Далее'));
      await pump();

      // Step 6: universities trust — no selection required.
      await tester.tap(find.text('Далее'));
      await pump();

      // Step 7: knowledge level — selection required.
      await tester.tap(find.text('Новичок'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Далее'));
      await pump();

      // Steps 8, 9, 10: no selection required.
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Далее'));
        await pump();
      }

      // Step 11 (_ThreeStepPlanStep): _NavArea is hidden; step has its own
      // FeaturedButton «Создать мой план».
      expect(find.text('Создать мой план'), findsOneWidget);
      await tester.tap(find.text('Создать мой план'));
      await pump();

      // Step 12 (_PlanCreationStep): with disableAnimations=true, fires a
      // 300 ms timer that calls onComplete() → moves to step 13.
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 50));

      // Step 13 (_FinishStep): shows «Начать».
      expect(find.text('Начать'), findsOneWidget);
      await tester.tap(find.text('Начать'));
      // _finish() is async: saves profile then calls context.go('/home').
      await tester.pump(); // trigger the async _finish() chain
      await tester.pump(const Duration(milliseconds: 100)); // repo save
      await tester.pump(const Duration(milliseconds: 300)); // go_router nav

      // Profile must have been saved with onboardingComplete=true.
      final saved = await repo.loadProfile();
      expect(saved.onboardingComplete, isTrue);
    },
  );
}
