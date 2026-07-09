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

  testWidgets('Motivation step shows exactly 3 option cards', (tester) async {
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

    // Motivation step heading.
    expect(find.text('Какова твоя цель?'), findsOneWidget);
    // Exactly 3 options.
    expect(find.text('Поступить в топ-вуз Казахстана'), findsOneWidget);
    expect(find.text('Поступить в вуз за рубежом'), findsOneWidget);
    expect(find.text('Профориентация'), findsOneWidget);
  });

  testWidgets('Confidence step shows 4 option cards', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    Future<void> pump() async {
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Step 0 → role.
    await tester.tap(find.text('Я учусь'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Далее'));
    await pump();

    // Step 1 → mascot greeting.
    await tester.tap(find.text('Далее'));
    await pump();

    // Step 2 → motivation (requires selection).
    await tester.tap(find.text('Поступить в топ-вуз Казахстана'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Далее'));
    await pump();

    // Step 3 → age (optional).
    await tester.tap(find.text('Далее'));
    await pump();

    // Step 4 → subject/majors (requires at least one).
    await tester.ensureVisible(find.text('Психология'));
    await tester.tap(find.text('Психология'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Далее'));
    await pump();

    // Step 5 → universities trust (optional).
    await tester.tap(find.text('Далее'));
    await pump();

    // Step 6 → confidence step.
    expect(find.text('Насколько ты уверен, что поступишь?'), findsOneWidget);
    expect(find.text('Уверен на 100%'), findsOneWidget);
    expect(find.text('Скорее да'), findsOneWidget);
    expect(find.text('Ещё не уверен'), findsOneWidget);
    expect(find.text('Только начинаю'), findsOneWidget);
  });

  testWidgets('Stats step is skippable without entering data', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    Future<void> pump() async {
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Navigate to step 7 (stats).
    await tester.tap(find.text('Я учусь'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Далее'));
    await pump();

    await tester.tap(find.text('Далее')); // mascot
    await pump();

    await tester.tap(find.text('Поступить в топ-вуз Казахстана'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Далее')); // motivation
    await pump();

    await tester.tap(find.text('Далее')); // age
    await pump();

    await tester.ensureVisible(find.text('Психология'));
    await tester.tap(find.text('Психология'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Далее')); // majors
    await pump();

    await tester.tap(find.text('Далее')); // trust
    await pump();

    await tester.tap(find.text('Уверен на 100%'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Далее')); // confidence
    await pump();

    // Step 7 → stats — heading visible, Далее should be enabled even with no input.
    expect(find.text('Твои академические показатели'), findsOneWidget);
    expect(find.text('ГПА / Средний балл'), findsOneWidget);
    expect(find.text('IELTS (если есть)'), findsOneWidget);
    expect(find.text('SAT (если есть)'), findsOneWidget);

    // Tap Далее without entering anything (step is always skippable).
    await tester.tap(find.text('Далее'));
    await pump();

    // Should be past stats now (on topic universe step).
    expect(find.text('Всё, что нужно — уже здесь'), findsOneWidget);
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

      // Step 2: motivation — selection required (3 options).
      await tester.tap(find.text('Поступить в топ-вуз Казахстана'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Далее'));
      await pump();

      // Step 3: age — no selection required (text field, defaults canAdvance=true).
      await tester.tap(find.text('Далее'));
      await pump();

      // Step 4: majors — at least one selection required.
      await tester.ensureVisible(find.text('Психология'));
      await tester.tap(find.text('Психология'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Далее'));
      await pump();

      // Step 5: universities trust — no selection required.
      await tester.tap(find.text('Далее'));
      await pump();

      // Step 6: confidence — selection required.
      await tester.tap(find.text('Уверен на 100%'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Далее'));
      await pump();

      // Step 7: stats — all optional, skip directly.
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

  testWidgets('_finish saves motivation and confidence fields', (tester) async {
    final repo = InMemoryProfileRepository();
    await tester.pumpWidget(_themed(const OnboardingScreen(), repo: repo));
    await tester.pumpAndSettle();

    Future<void> pump() async {
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Blaze through all steps quickly.
    await tester.tap(find.text('Я учусь'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Далее'));
    await pump();

    await tester.tap(find.text('Далее')); // mascot
    await pump();

    await tester.tap(find.text('Поступить в вуз за рубежом'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Далее')); // motivation
    await pump();

    await tester.tap(find.text('Далее')); // age
    await pump();

    await tester.ensureVisible(find.text('Математика'));
    await tester.tap(find.text('Математика'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Далее')); // majors
    await pump();

    await tester.tap(find.text('Далее')); // trust
    await pump();

    await tester.tap(find.text('Скорее да'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Далее')); // confidence
    await pump();

    await tester.tap(find.text('Далее')); // stats (skip)
    await pump();

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Далее'));
      await pump();
    }

    await tester.tap(find.text('Создать мой план'));
    await pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Начать'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    final saved = await repo.loadProfile();
    expect(saved.motivation, equals('Поступить в вуз за рубежом'));
    expect(saved.confidence, equals('Скорее да'));
    expect(saved.studyPlan, isNotEmpty);
    // Study plan should have content derived from the major.
    expect(saved.studyPlan.any((s) => s.isNotEmpty), isTrue);
  });
}
