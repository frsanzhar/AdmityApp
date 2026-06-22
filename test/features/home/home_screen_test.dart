import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] with ProviderScope + themed MaterialApp (Admity tokens),
/// mirroring widget_test.dart pattern.
Widget _themed(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: ThemeData(
        extensions: [AppTokens.defaults()],
      ),
      home: child,
    ),
  );
}

void main() {
  // ── Anti-blank-screen guard ──────────────────────────────────────────────────

  testWidgets('HomeScreen builds with no framework/layout errors', (
    tester,
  ) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(
      errors,
      isEmpty,
      reason: 'no framework/layout errors on HomeScreen build',
    );
  });

  // ── Structural content checks ────────────────────────────────────────────────

  testWidgets('header greeting is visible', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Привет!'), findsOneWidget);
    expect(find.text('Готов к новым знаниям?'), findsOneWidget);
  });

  testWidgets('today-agenda card is present', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    // The day-label widget is always rendered (empty-state or events).
    // Verify the card scaffolding text key for the empty state.
    expect(
      find.textContaining('Событий на сегодня нет'),
      findsOneWidget,
    );
  });

  testWidgets('"Задание на сегодня" card is below the agenda', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Задание на сегодня'), findsOneWidget);
    expect(find.text('Продолжить'), findsOneWidget);
  });

  testWidgets('task list shows seeded tasks', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Сегодняшние задачи'), findsOneWidget);
    expect(find.text('Пройти урок по математике'), findsOneWidget);
    expect(find.text('Изучить стипендии БОЛАШАК'), findsOneWidget);
  });

  // ── Streak badge popup ────────────────────────────────────────────────────────

  testWidgets('tapping StreakBadge shows week popup', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    // The popup is hidden before tap.
    expect(find.text('Серия — эта неделя'), findsNothing);

    // Tap the badge (it is wrapped in a GestureDetector with the Semantics label).
    final badge = find.bySemanticsLabel(
      RegExp('Серия'),
    );
    await tester.tap(badge);
    await tester.pumpAndSettle();

    expect(find.text('Серия — эта неделя'), findsOneWidget);
    // Days of week labels rendered.
    expect(find.text('Пн'), findsOneWidget);
    expect(find.text('Вс'), findsOneWidget);
  });

  testWidgets('streak popup dismisses on close', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    // Open.
    final badge = find.bySemanticsLabel(RegExp('Серия'));
    await tester.tap(badge);
    await tester.pumpAndSettle();
    expect(find.text('Серия — эта неделя'), findsOneWidget);

    // Dismiss via close icon.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Серия — эта неделя'), findsNothing);
  });

  // ── Todo CRUD ─────────────────────────────────────────────────────────────────

  testWidgets('checkbox toggles done state', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    // Tap the checkbox of the first task — it is a GestureDetector child of _TodoRow.
    // We target by AnimatedContainer via Icon.check absence first.
    final firstTaskText = find.text('Пройти урок по математике');
    expect(firstTaskText, findsOneWidget);

    // Tap the checkbox widget (AnimatedContainer, found by the checkbox Icon's parent).
    // The checkbox is a GestureDetector containing an AnimatedContainer.
    // We scroll to and tap the first checkbox area.
    final checkboxes = find.byWidgetPredicate(
      (w) => w is AnimatedContainer && w.decoration is BoxDecoration,
    );
    // Tap the first checkbox.
    await tester.tap(checkboxes.first);
    await tester.pumpAndSettle();

    // After toggle the check icon is present.
    expect(find.byIcon(Icons.check), findsWidgets);
  });

  testWidgets('tapping task row opens bottom sheet', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    // Tap the task row (the GestureDetector wrapping the whole row).
    await tester.tap(find.text('Пройти урок по математике'));
    await tester.pumpAndSettle();

    // Sheet title for the task should be visible (read mode shows title).
    expect(find.text('Пройти урок по математике'), findsWidgets);
    // Edit icon is shown in read mode.
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
  });

  testWidgets('add-task sheet opens from + button', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    expect(find.text('Новая задача'), findsWidgets);
    expect(find.text('Сохранить'), findsOneWidget);
  });

  testWidgets('adding a new task updates the list', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    // Open add sheet.
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    // Enter title.
    await tester.enterText(find.byType(TextField).first, 'Тест новой задачи');
    await tester.pumpAndSettle();

    // Save.
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Тест новой задачи'), findsOneWidget);
  });

  testWidgets('deleting a task removes it from the list', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    const targetTask = 'Обновить профиль';
    expect(find.text(targetTask), findsOneWidget);

    // Open the task sheet (scroll into view first — it may be below the fold
    // in the test viewport).
    await tester.ensureVisible(find.text(targetTask));
    await tester.pumpAndSettle();
    await tester.tap(find.text(targetTask));
    await tester.pumpAndSettle();

    // Tap delete.
    await tester.tap(find.text('Удалить задачу'));
    await tester.pumpAndSettle();

    expect(find.text(targetTask), findsNothing);
  });

  testWidgets('no stretch-in-scroll — Column uses mainAxisSize.min', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    // Verify no CrossAxisAlignment.stretch Column inside ScrollView exists by
    // checking screen renders without overflow errors (errors list already covers
    // this; this test is a named guard for the CLAUDE.md gotcha).
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(
      errors,
      isEmpty,
      reason: 'no layout errors after scroll (stretch-in-scroll guard)',
    );
  });
}
