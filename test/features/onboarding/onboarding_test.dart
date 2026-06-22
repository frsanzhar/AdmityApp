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

  testWidgets('First step shows welcome text', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Добро пожаловать в Admity'), findsOneWidget);
  });

  testWidgets('Progress bar is present on step 0', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // The segmented progress bar uses AnimatedContainers in a Row.
    // We verify it renders by checking for at least one AnimatedContainer.
    expect(find.byType(AnimatedContainer), findsWidgets);
  });

  testWidgets('Далее advances to feature step 1', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // Step 0 is welcome — tap Далее.
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();

    expect(find.text('Честный прогноз шансов'), findsOneWidget);
  });

  testWidgets('Back button absent on step 0', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Далее'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
  });

  testWidgets('Back button present after step 1', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('City step shows city field and Алматы chip', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // Navigate to step 5 (city): tap Далее 5 times
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Далее'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Из какого ты города?'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Алматы'), findsOneWidget);
  });

  testWidgets(
    'onboardingComplete saved on finish via Начать',
    (tester) async {
      final repo = InMemoryProfileRepository();
      await tester.pumpWidget(_themed(const OnboardingScreen(), repo: repo));
      await tester.pumpAndSettle();

      // Navigate steps 0..11 (12 taps of Далее reaches step 12 reveal).
      // pumpAndSettle is safe here because each step is non-auto-advancing.
      for (var i = 0; i < 12; i++) {
        await tester.tap(find.text('Далее'));
        // Use pump with a short duration rather than pumpAndSettle for the
        // AnimatedSwitcher transition, then settle.
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Step 12 is the reveal. With disableAnimations=true (set globally in
      // flutter_test_config.dart), _PlanRevealStep._startSequence() fires a
      // 300 ms timer that calls onRevealComplete() → advances to step 13.
      // Pump past that timer.
      await tester.pump(const Duration(milliseconds: 350));
      // Pump once more to process the setState triggered by the timer.
      await tester.pump(const Duration(milliseconds: 50));

      // Now on step 13 (completion). Find and tap "Начать".
      expect(find.text('Начать'), findsOneWidget);
      await tester.tap(find.text('Начать'));
      // _finish() is async: saves profile then calls context.go('/home').
      // Use pump cycles rather than pumpAndSettle to avoid blocking on the
      // GoRouter navigation animation.
      await tester.pump(); // trigger the async _finish() chain
      await tester.pump(const Duration(milliseconds: 100)); // repo save
      await tester.pump(const Duration(milliseconds: 300)); // go_router nav

      // Profile must have been saved with onboardingComplete=true before the
      // navigation happens (saveProfile is called before context.go).
      final saved = await repo.loadProfile();
      expect(saved.onboardingComplete, isTrue);
    },
  );
}
