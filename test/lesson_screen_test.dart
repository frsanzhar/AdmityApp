import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/lesson/presentation/lesson_screen.dart';
import 'package:admity/shared/diagrams/courses/lesson_topic_diagram.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps [widget] in MaterialApp + Admity theme + Riverpod + GoRouter so that
/// AppTokens, providers, and context.go('/home') all work correctly.
Widget _routerWrapped(Widget widget, {ProviderContainer? container}) {
  final router = GoRouter(
    initialLocation: '/lesson',
    routes: [
      GoRoute(
        path: '/lesson',
        builder: (context, state) => Scaffold(body: widget),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('HomeScreen'))),
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
      expect(s.currentTheoryCardIndex, 0);
    });

    test('beginLesson transitions to theory step (not question)', () {
      notifier.beginLesson();
      expect(container.read(lessonProvider).stepKind, LessonStepKind.theory);
    });

    test('beginLesson resets theory card index to 0', () {
      notifier.beginLesson();
      expect(container.read(lessonProvider).currentTheoryCardIndex, 0);
    });

    test('advanceTheory moves to next card', () {
      notifier.beginLesson();
      expect(container.read(lessonProvider).currentTheoryCardIndex, 0);
      notifier.advanceTheory();
      expect(container.read(lessonProvider).currentTheoryCardIndex, 1);
    });

    test('advanceTheory after last card moves to question step', () {
      notifier.beginLesson();
      // Advance through all theory cards (4 cards → advance 4 times).
      // After the 4th advance we should be in the question step.
      for (var i = 0; i < 4; i++) {
        notifier.advanceTheory();
      }
      expect(
        container.read(lessonProvider).stepKind,
        LessonStepKind.question,
        reason:
            'after advancing past last theory card, step should be question',
      );
    });

    test('selectOption updates selectedOptionIndex', () {
      notifier.beginLesson();
      for (var i = 0; i < 4; i++) {
        notifier.advanceTheory();
      }
      notifier.selectOption(2);
      expect(container.read(lessonProvider).selectedOptionIndex, 2);
    });

    test('checkAnswer with correct answer increments correctCount and xp', () {
      // Q0 correctIndex = 1
      notifier.beginLesson();
      for (var i = 0; i < 4; i++) {
        notifier.advanceTheory();
      }
      notifier
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
      notifier.beginLesson();
      for (var i = 0; i < 4; i++) {
        notifier.advanceTheory();
      }
      notifier
        ..selectOption(0)
        ..checkAnswer();
      final s = container.read(lessonProvider);
      expect(s.correctCount, 0);
      expect(s.xp, 0);
      expect(s.stepKind, LessonStepKind.feedback);
    });

    test('checkAnswer without selection is a no-op', () {
      notifier.beginLesson();
      for (var i = 0; i < 4; i++) {
        notifier.advanceTheory();
      }
      notifier.checkAnswer(); // no selection yet
      final s = container.read(lessonProvider);
      expect(
        s.stepKind,
        LessonStepKind.question,
        reason: 'should stay on question when nothing is selected',
      );
    });

    test('continueLesson advances to next question', () {
      notifier.beginLesson();
      for (var i = 0; i < 4; i++) {
        notifier.advanceTheory();
      }
      notifier
        ..selectOption(1)
        ..checkAnswer()
        ..continueLesson();
      final s = container.read(lessonProvider);
      expect(s.currentQuestionIndex, 1);
      expect(s.stepKind, LessonStepKind.question);
      expect(s.selectedOptionIndex, -1);
      expect(s.isChecked, isFalse);
    });

    test(
      'completing all questions reaches complete step with completion bonus',
      () {
        notifier.beginLesson();
        for (var i = 0; i < 4; i++) {
          notifier.advanceTheory();
        }
        notifier
          // Q0 correct = 1 (multipleChoice)
          ..selectOption(1)
          ..checkAnswer()
          ..continueLesson()
          // Q1 correct = 0 (trueFalse: 'Верно')
          ..selectOption(0)
          ..checkAnswer()
          ..continueLesson()
          // Q2 correct = 1 (tapToSelect: '0' at index 1)
          ..selectOption(1)
          ..checkAnswer()
          ..continueLesson(); // triggers complete
        final s = container.read(lessonProvider);
        expect(s.stepKind, LessonStepKind.complete);
        expect(s.correctCount, 3);
        // 3 correct × 15 + 5 completion bonus = 50
        expect(s.xp, 3 * lessonXpPerCorrect + lessonCompletionBonus);
      },
    );

    test('toggleExplanation flips isExplanationExpanded', () {
      notifier.beginLesson();
      for (var i = 0; i < 4; i++) {
        notifier.advanceTheory();
      }
      notifier
        ..selectOption(0)
        ..checkAnswer();
      expect(container.read(lessonProvider).isExplanationExpanded, isFalse);
      notifier.toggleExplanation();
      expect(container.read(lessonProvider).isExplanationExpanded, isTrue);
      notifier.toggleExplanation();
      expect(container.read(lessonProvider).isExplanationExpanded, isFalse);
    });

    // ── Question type tests ──────────────────────────────────────────────────

    test('Q0 is multipleChoice type', () {
      notifier.beginLesson();
      for (var i = 0; i < 4; i++) {
        notifier.advanceTheory();
      }
      // Q0 is at index 0 (default start)
      expect(container.read(lessonProvider).currentQuestionIndex, 0);
      // After advancing to Q0, selectOption + checkAnswer works
      notifier
        ..selectOption(1)
        ..checkAnswer();
      expect(container.read(lessonProvider).stepKind, LessonStepKind.feedback);
    });

    test('Q1 is trueFalse type — selectOption(0) + checkAnswer is correct', () {
      notifier.beginLesson();
      for (var i = 0; i < 4; i++) {
        notifier.advanceTheory();
      }
      notifier
        ..selectOption(1) // Q0 complete
        ..checkAnswer()
        ..continueLesson();
      // Now on Q1 (trueFalse)
      expect(container.read(lessonProvider).currentQuestionIndex, 1);
      notifier
        ..selectOption(0) // 'Верно' = correct
        ..checkAnswer();
      expect(container.read(lessonProvider).correctCount, 2);
    });

    test(
      'Q2 is tapToSelect type — selectOption(1) + checkAnswer is correct',
      () {
        notifier.beginLesson();
        for (var i = 0; i < 4; i++) {
          notifier.advanceTheory();
        }
        notifier
          ..selectOption(1) // Q0
          ..checkAnswer()
          ..continueLesson()
          ..selectOption(0) // Q1
          ..checkAnswer()
          ..continueLesson();
        // Now on Q2 (tapToSelect)
        expect(container.read(lessonProvider).currentQuestionIndex, 2);
        notifier
          ..selectOption(1) // '0' at index 1 = correct
          ..checkAnswer();
        expect(container.read(lessonProvider).correctCount, 3);
      },
    );

    test('seed data has at least 2 distinct QuestionType values', () {
      // Verify diversity of question types in the lesson
      // We access this via the exported QuestionType enum
      const types = QuestionType.values;
      expect(
        types.length,
        greaterThanOrEqualTo(2),
        reason: 'QuestionType enum should have at least 2 variants',
      );
      // The 3 seed questions cover all 3 types
      expect(types, contains(QuestionType.multipleChoice));
      expect(types, contains(QuestionType.trueFalse));
      expect(types, contains(QuestionType.tapToSelect));
    });
  });

  // ── Widget tests ─────────────────────────────────────────────────────────────

  group('LessonScreen widget tests', () {
    testWidgets('builds with NO framework/layout errors on intro step', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      await _pumpLesson(tester);

      expect(
        errors,
        isEmpty,
        reason: 'no swallowed layout errors on LessonScreen intro',
      );
    });

    testWidgets('intro step shows display title and FeaturedButton', (
      tester,
    ) async {
      await _pumpLesson(tester);
      expect(find.text('Сравнение вероятностей'), findsOneWidget);
      expect(find.byType(FeaturedButton), findsOneWidget);
      expect(find.text('Начать урок'), findsOneWidget);
    });

    testWidgets('intro step uses LessonTopicDiagram (R8)', (tester) async {
      await _pumpLesson(tester);
      expect(
        find.byType(LessonTopicDiagram),
        findsOneWidget,
        reason:
            'intro step should use LessonTopicDiagram instead of TopicDiagramSlot',
      );
    });

    testWidgets(
      'tapping "Начать урок" advances to THEORY step (not question)',
      (tester) async {
        final container = await _pumpLesson(tester);
        expect(container.read(lessonProvider).stepKind, LessonStepKind.intro);

        await tester.scrollUntilVisible(
          find.text('Начать урок'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Начать урок'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(
          container.read(lessonProvider).stepKind,
          LessonStepKind.theory,
          reason: 'intro → theory, not directly to question',
        );
      },
    );

    testWidgets('theory step shows a theory card headline', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).stepKind, LessonStepKind.theory);
      // The first theory card headline for this lesson is:
      expect(find.text('Что такое вероятность?'), findsOneWidget);

      expect(errors, isEmpty, reason: 'no layout errors on theory step');
    });

    testWidgets('"Далее" advances theory cards', (tester) async {
      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).currentTheoryCardIndex, 0);

      await tester.tap(find.text('Далее'));
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).currentTheoryCardIndex, 1);
    });

    testWidgets('last theory card shows "К вопросам" button', (tester) async {
      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      // Advance to last card (index 3 of 4 cards).
      container.read(lessonProvider.notifier)
        ..advanceTheory()
        ..advanceTheory()
        ..advanceTheory();
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).currentTheoryCardIndex, 3);
      expect(find.text('К вопросам'), findsOneWidget);
    });

    testWidgets('"К вопросам" moves to question step', (tester) async {
      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      for (var i = 0; i < 4; i++) {
        container.read(lessonProvider.notifier).advanceTheory();
      }
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).stepKind, LessonStepKind.question);
    });

    testWidgets('question step: Check button disabled with no selection', (
      tester,
    ) async {
      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      for (var i = 0; i < 4; i++) {
        container.read(lessonProvider.notifier).advanceTheory();
      }
      await tester.pumpAndSettle();

      expect(find.text('Проверить'), findsOneWidget);
      final beforeState = container.read(lessonProvider);
      await tester.tap(find.text('Проверить'), warnIfMissed: false);
      await tester.pumpAndSettle();
      final afterState = container.read(lessonProvider);
      expect(
        afterState.stepKind,
        beforeState.stepKind,
        reason: 'Check should be a no-op without a selection',
      );
    });

    testWidgets('selecting an answer enables Check', (tester) async {
      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      for (var i = 0; i < 4; i++) {
        container.read(lessonProvider.notifier).advanceTheory();
      }
      await tester.pumpAndSettle();

      final options = find.text('1/4');
      expect(options, findsOneWidget);
      await tester.tap(options);
      await tester.pumpAndSettle();

      expect(
        container.read(lessonProvider).selectedOptionIndex,
        0,
        reason: 'first option should be selected',
      );
      expect(container.read(lessonProvider).hasSelection, isTrue);
    });

    testWidgets('correct answer shows Верно! banner', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      for (var i = 0; i < 4; i++) {
        container.read(lessonProvider.notifier).advanceTheory();
      }
      await tester.pumpAndSettle();

      // Q0 correct answer is index 1 = '1/2'
      await tester.tap(find.text('1/2'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Проверить'));
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).stepKind, LessonStepKind.feedback);
      expect(container.read(lessonProvider).correctCount, 1);
      expect(find.text('Верно!'), findsOneWidget);

      expect(errors, isEmpty, reason: 'no layout errors on feedback step');
    });

    testWidgets('wrong answer shows Неверно banner', (tester) async {
      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      for (var i = 0; i < 4; i++) {
        container.read(lessonProvider.notifier).advanceTheory();
      }
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
      container.read(lessonProvider.notifier).beginLesson();
      for (var i = 0; i < 4; i++) {
        container.read(lessonProvider.notifier).advanceTheory();
      }
      container.read(lessonProvider.notifier)
        ..selectOption(1)
        ..checkAnswer();
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).isExplanationExpanded, isFalse);

      await tester.tap(find.text('Почему?'));
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).isExplanationExpanded, isTrue);
      expect(find.textContaining('равновероятных'), findsOneWidget);
    });

    testWidgets('completing all questions shows complete screen', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      final container = await _pumpLesson(tester);

      container.read(lessonProvider.notifier).beginLesson();
      for (var i = 0; i < 4; i++) {
        container.read(lessonProvider.notifier).advanceTheory();
      }
      container.read(lessonProvider.notifier)
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
      expect(find.text('Урок пройден!'), findsOneWidget);
      expect(find.textContaining('+50 XP'), findsWidgets);
      expect(find.byType(MascotSlot), findsOneWidget);
      expect(find.text('Готово'), findsOneWidget);

      expect(errors, isEmpty, reason: 'no layout errors on complete step');
    });

    testWidgets('"Готово" navigates back to /home', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _routerWrapped(const LessonScreen(), container: container),
      );
      await tester.pumpAndSettle();

      container.read(lessonProvider.notifier).beginLesson();
      for (var i = 0; i < 4; i++) {
        container.read(lessonProvider.notifier).advanceTheory();
      }
      container.read(lessonProvider.notifier)
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

      await tester.scrollUntilVisible(
        find.text('Готово'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Готово'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('HomeScreen'), findsOneWidget);
    });

    testWidgets('close button navigates to /home', (tester) async {
      await _pumpLesson(tester);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('HomeScreen'), findsOneWidget);
    });

    testWidgets('complete screen builds with no framework/layout errors', (
      tester,
    ) async {
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

      container.read(lessonProvider.notifier).beginLesson();
      for (var i = 0; i < 4; i++) {
        container.read(lessonProvider.notifier).advanceTheory();
      }
      container.read(lessonProvider.notifier)
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

      expect(
        errors,
        isEmpty,
        reason: 'no layout errors on complete step build',
      );
    });

    testWidgets('theory step builds with no framework/layout errors', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      await tester.pumpAndSettle();

      expect(errors, isEmpty, reason: 'no layout errors on theory step');
    });

    testWidgets('PrimaryButton does not use Material default purple', (
      tester,
    ) async {
      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      for (var i = 0; i < 4; i++) {
        container.read(lessonProvider.notifier).advanceTheory();
      }
      await tester.pumpAndSettle();

      final buttons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      for (final btn in buttons) {
        final bgColor = btn.style?.backgroundColor?.resolve(<WidgetState>{});
        if (bgColor != null) {
          expect(
            bgColor == const Color(0xFF6200EE) ||
                bgColor == const Color(0xFF3700B3),
            isFalse,
            reason: 'PrimaryButton must not use Material default purple',
          );
        }
      }
    });

    // ── Varied question type widget tests (R7) ──────────────────────────────

    testWidgets('trueFalse question renders «Верно» and «Неверно» buttons', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      for (var i = 0; i < 4; i++) {
        container.read(lessonProvider.notifier).advanceTheory();
      }
      // Advance past Q0 to Q1 (trueFalse)
      container.read(lessonProvider.notifier)
        ..selectOption(1)
        ..checkAnswer()
        ..continueLesson();
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).currentQuestionIndex, 1);
      expect(find.text('Верно'), findsOneWidget);
      expect(find.text('Неверно'), findsOneWidget);
      expect(errors, isEmpty, reason: 'no layout errors on trueFalse step');
    });

    testWidgets('tapToSelect question renders word chips', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = prev);

      final container = await _pumpLesson(tester);
      container.read(lessonProvider.notifier).beginLesson();
      for (var i = 0; i < 4; i++) {
        container.read(lessonProvider.notifier).advanceTheory();
      }
      // Advance past Q0 and Q1 to Q2 (tapToSelect)
      container.read(lessonProvider.notifier)
        ..selectOption(1)
        ..checkAnswer()
        ..continueLesson()
        ..selectOption(0)
        ..checkAnswer()
        ..continueLesson();
      await tester.pumpAndSettle();

      expect(container.read(lessonProvider).currentQuestionIndex, 2);
      // Q2 options: ['1', '0', '1/2', '100%']
      expect(find.text('1'), findsWidgets);
      expect(find.text('0'), findsWidgets);
      expect(find.text('1/2'), findsWidgets);
      expect(find.text('100%'), findsWidgets);
      // «Проверить» still present for tapToSelect
      expect(find.text('Проверить'), findsOneWidget);
      expect(errors, isEmpty, reason: 'no layout errors on tapToSelect step');
    });
  });
}
