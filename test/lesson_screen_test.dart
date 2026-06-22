import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/lesson/presentation/lesson_screen.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps [widget] in MaterialApp + Admity theme + Riverpod + GoRouter so that
/// AppTokens, providers, and context.go('/courses') all work correctly.
Widget _routerWrapped(Widget widget, {ProviderContainer? container}) {
  final router = GoRouter(
    initialLocation: '/lesson',
    routes: [
      GoRoute(
        path: '/lesson',
        builder: (context, state) => Scaffold(body: widget),
      ),
      GoRoute(
        path: '/courses',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('CoursesScreen'))),
      ),
    ],
  );

  if (container != null) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(extensions: [AppTokens.defaults()]),
      ),
    );
  }

  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(extensions: [AppTokens.defaults()]),
    ),
  );
}

/// Pumps a fresh [LessonScreen] and returns the provider container so state
/// can be inspected / driven after the pump.
Future<ProviderContainer> _pumpLesson(WidgetTester tester) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    _routerWrapped(const LessonScreen(), container: container),
  );
  await tester.pumpAndSettle();
  return container;
}

// ── Unit tests: LessonNotifier ────────────────────────────────────────────────

void main() {
  group('LessonNotifier unit tests', () {
    late ProviderContainer container;
    late LessonNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(lessonProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('initial state is intro with no selection and 0 xp', () {
      final s = container.read(lessonProvider);
      expect(s.stepKind, LessonStepKind.intro);
      expect(s.selectedOptionIndex, -1);
      expect(s.correctCount, 0);
      expect(s.xp, 0);
      expect(s.isChecked, isFalse);
    });

    test('beginLesson transitions to question step', () {
      notifier.beginLesson();
      expect(container.read(lessonProvider).stepKind, LessonStepKind.question);
    });

    test('selectOption updates selectedOptionIndex', () {
      notifier
        ..beginLesson()
        ..selectOption(2);
      expect(container.read(lessonProvider).selectedOptionIndex, 2);
    });

    test('checkAnswer with correct answer increments correctCount and xp', () {
      // Q0 correctIndex = 1
      notifier
        ..beginLesson()
        ..selectOption(1)
        ..checkAnswer();
      final s = container.read(lessonProvider);
      expect(s.correctCount, 1);
      expect(s.xp, lessonXpPerCorrect);
      expect(s.stepKind, LessonStepKind.feedback);
      expect(s.isChecked, isTrue);
    });

    test('checkAnswer with wrong answer does not increment correctCount', () {
      // Q0 correctIndex = 1; we pick 0 (wrong)
      notifier
        ..beginLesson()
        ..selectOption(0)
        ..checkAnswer();
      final s = container.read(lessonProvider);
      expect(s.correctCount, 0);
      expect(s.xp, 0);
      expect(s.stepKind, LessonStepKind.feedback);
    });

    test('checkAnswer without selection is a no-op', () {
      notifier
        ..beginLesson()
        ..checkAnswer(); // no selection yet
      final s = container.read(lessonProvider);
      expect(s.stepKind, LessonStepKind.question,
          reason: 'should stay on question when nothing is selected');
    });

    test('continueLesson advances to next question', () {
      notifier
        ..beginLesson()
        ..selectOption(1)
        ..checkAnswer()
        ..continueLesson();
      final s = container.read(lessonProvider);
      expect(s.currentQuestionIndex, 1);
      expect(s.stepKind, LessonStepKind.question);
      expect(s.selectedOptionIndex, -1);
      expect(s.isChecked, isFalse);
    });

    test('completing all questions reaches complete step with completion bonus',
        () {
      notifier
        ..beginLesson()
        // Q0 correct = 1
        ..selectOption(1)
        ..checkAnswer()
        ..continueLesson()
        // Q1 correct = 0
        ..selectOption(0)
        ..checkAnswer()
        ..continueLesson()
        // Q2 correct = 1
        ..selectOption(1)
        ..checkAnswer()
        ..continueLesson(); // triggers complete
      final s = container.read(lessonProvider);
      expect(s.stepKind, LessonStepKind.complete);
      expect(s.correctCount, 3);
      // 3 correct × 15 + 5 completion bonus = 50
      expect(s.xp, 3 * lessonXpPerCorrect + lessonCompletionBonus);
    });

    test('toggleExplanation flips isExplanationExpanded', () {
      notifier
        ..beginLesson()
        ..selectOption(0)
        ..checkAnswer();
      expect(container.read(lessonProvider).isExplanationExpanded, isFalse);
      notifier.toggleExplanation();
      expect(container.read(lessonProvider).isExplanationExpanded, isTrue);
      notifier.toggleExplanation();
      expect(container.read(lessonProvider).isExplanationExpanded, isFalse);
    });
  });

  // ── Widget tests ─────────────────────────────────────────────────────────────

  group('LessonScreen widget tests', () {
    testWidgets('builds with NO framework/layout errors on intro step',
        (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await _pumpLesson(tester);

      expect(errors, isEmpty,
          reason: 'no swallowed layout errors on LessonScreen intro');
    });

    testWidgets('intro step shows display title and FeaturedButton',
        (tester) async {
      await _pumpLesson(tester);
      expect(find.text('Сравнение вероятностей'), findsOneWidget);
      expect(find.byType(FeaturedButton), findsOneWidget);
      expect(find.text('Начать урок'), findsOneWidget);
    });

    testWidgets('tapping "Начать урок" advances to question step',
        (tester) async {
      final container = await _pumpLesson(tester);
      expect(container.read(lessonProvider).stepKind, LessonStepKind.intro);

      // FeaturedButton may be below the test viewport; scroll to it first.
      await tester.scrollUntilVisible(
        find.text('Начать урок'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Начать урок'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
          container.read(lessonProvider).stepKind, LessonStepKind.question);
    });

    testWidgets('question step: Check button disabled with no selection',
        (tester) async {
      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      await tester.pumpAndSettle();

      // Find PrimaryButton "Проверить"
      expect(find.text('Проверить'), findsOneWidget);
      // The button should be disabled (onPressed = null → ElevatedButton is
      // inactive; tap should not change state)
      final beforeState = container.read(lessonProvider);
      await tester.tap(find.text('Проверить'), warnIfMissed: false);
      await tester.pumpAndSettle();
      final afterState = container.read(lessonProvider);
      expect(afterState.stepKind, beforeState.stepKind,
          reason: 'Check should be a no-op without a selection');
    });

    testWidgets('selecting an answer enables Check', (tester) async {
      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      await tester.pumpAndSettle();

      // Tap the first option
      final options = find.text('1/4');
      expect(options, findsOneWidget);
      await tester.tap(options);
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).selectedOptionIndex, 0,
          reason: 'first option should be selected');
      expect(container.read(lessonProvider).hasSelection, isTrue);
    });

    testWidgets('correct answer shows Верно! banner', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      await tester.pumpAndSettle();

      // Q0 correct answer is index 1 = '1/2'
      await tester.tap(find.text('1/2'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Проверить'));
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).stepKind, LessonStepKind.feedback);
      expect(container.read(lessonProvider).correctCount, 1);
      // "Верно!" text should appear
      expect(find.text('Верно!'), findsOneWidget);

      expect(errors, isEmpty, reason: 'no layout errors on feedback step');
    });

    testWidgets('wrong answer shows Неверно banner', (tester) async {
      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      await tester.pumpAndSettle();

      // Q0 wrong answer is index 0 = '1/4'
      await tester.tap(find.text('1/4'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Проверить'));
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).correctCount, 0);
      expect(find.text('Неверно'), findsOneWidget);
    });

    testWidgets('Почему? expander reveals explanation on tap', (tester) async {
      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier)
        ..beginLesson()
        ..selectOption(1)
        ..checkAnswer();
      await tester.pumpAndSettle();

      // Explanation should be hidden initially
      expect(container.read(lessonProvider).isExplanationExpanded, isFalse);

      await tester.tap(find.text('Почему?'));
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).isExplanationExpanded, isTrue);
      // Explanation text snippet should now be visible
      expect(find.textContaining('равновероятных'), findsOneWidget);
    });

    testWidgets('completing all questions shows complete screen', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      final container = await _pumpLesson(tester);

      // Fast-forward through all questions via notifier directly.
      container.read(lessonProvider.notifier)
        ..beginLesson()
        ..selectOption(1) // Q0 correct
        ..checkAnswer()
        ..continueLesson()
        ..selectOption(0) // Q1 correct
        ..checkAnswer()
        ..continueLesson()
        ..selectOption(1) // Q2 correct
        ..checkAnswer()
        ..continueLesson(); // → complete
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).stepKind, LessonStepKind.complete);
      // "Урок пройден!" headline
      expect(find.text('Урок пройден!'), findsOneWidget);
      // XP shown: 3×15 + 5 = 50
      expect(find.textContaining('+50 XP'), findsWidgets);
      // MascotSlot present
      expect(find.byType(MascotSlot), findsOneWidget);
      // FeaturedButton "Готово"
      expect(find.text('Готово'), findsOneWidget);

      expect(errors, isEmpty, reason: 'no layout errors on complete step');
    });

    testWidgets('"Готово" navigates back to /courses', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _routerWrapped(const LessonScreen(), container: container),
      );
      await tester.pumpAndSettle();

      container.read(lessonProvider.notifier)
        ..beginLesson()
        ..selectOption(1)
        ..checkAnswer()
        ..continueLesson()
        ..selectOption(0)
        ..checkAnswer()
        ..continueLesson()
        ..selectOption(1)
        ..checkAnswer()
        ..continueLesson();
      await tester.pumpAndSettle();

      // Complete screen may require scroll to reach "Готово".
      await tester.scrollUntilVisible(
        find.text('Готово'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Готово'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('CoursesScreen'), findsOneWidget);
    });

    testWidgets('close button navigates to /courses', (tester) async {
      await _pumpLesson(tester);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('CoursesScreen'), findsOneWidget);
    });

    testWidgets('complete screen builds with no framework/layout errors',
        (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _routerWrapped(const LessonScreen(), container: container),
      );
      await tester.pumpAndSettle();

      container.read(lessonProvider.notifier)
        ..beginLesson()
        ..selectOption(1)
        ..checkAnswer()
        ..continueLesson()
        ..selectOption(0)
        ..checkAnswer()
        ..continueLesson()
        ..selectOption(1)
        ..checkAnswer()
        ..continueLesson();
      await tester.pumpAndSettle();

      expect(errors, isEmpty,
          reason: 'no layout errors on complete step build');
    });

    testWidgets('PrimaryButton does not use Material default purple',
        (tester) async {
      // Runtime check: ElevatedButton backing PrimaryButton must not inherit
      // the Material purple default — it should be AppColors.ink.
      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      await tester.pumpAndSettle();

      final buttons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      for (final btn in buttons) {
        final bgColor =
            btn.style?.backgroundColor?.resolve(<WidgetState>{});
        if (bgColor != null) {
          // Should never be Material default purple.
          expect(
            bgColor == const Color(0xFF6200EE) ||
                bgColor == const Color(0xFF3700B3),
            isFalse,
            reason: 'PrimaryButton must not use Material default purple',
          );
        }
      }
    });
  });
}
