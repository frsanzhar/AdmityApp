import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _themed(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: ThemeData(extensions: [AppTokens.defaults()]),
      home: child,
    ),
  );
}

void main() {
  // ── Anti-blank-screen guard ──────────────────────────────────────────────────

  testWidgets('HomeScreen builds without layout/framework errors', (
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

  // ── Structural checks ────────────────────────────────────────────────────────

  testWidgets('header greeting is visible', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Привет!'), findsOneWidget);
    expect(find.text('Готов к новым знаниям?'), findsOneWidget);
  });

  testWidgets('streak week card is always visible', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Серия — 7 дней'), findsOneWidget);
    // Day labels appear in both the streak row and the calendar weekday header,
    // so use findsWidgets (not findsOneWidget) — we just need them present.
    expect(find.text('Пн'), findsWidgets);
    expect(find.text('Вс'), findsWidgets);
  });

  testWidgets('tapping a streak day shows its state label', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    // The streak section '_StreakWeekSection' renders day labels inside
    // GestureDetectors.  The calendar weekday header also renders 'Пн', so we
    // must tap the first match (inside the streak card, which comes first in
    // the widget tree).
    await tester.tap(find.text('Пн').first);
    await tester.pumpAndSettle();

    expect(find.text('День завершён!'), findsOneWidget);

    // Tap "Чт" (Thursday = index 3, lit = false). Also use .first in case
    // calendar header duplicates it.
    await tester.tap(find.text('Чт').first);
    await tester.pumpAndSettle();

    expect(find.text('Этот день пропущен'), findsOneWidget);
  });

  testWidgets('calendar card is visible', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    // The calendar month header has exactly one chevron_left and one
    // chevron_right, but todo-row chevron_rights also exist, so use
    // findsWidgets for both and verify at least one of each is shown.
    expect(find.byIcon(Icons.chevron_left), findsWidgets);
    expect(find.byIcon(Icons.chevron_right), findsWidgets);
    // Weekday labels are always present in the calendar header.
    expect(find.text('Пн'), findsWidgets);
  });

  testWidgets('"Добавить событие" button is present in calendar', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Добавить событие'), findsOneWidget);
  });

  testWidgets('career test card is visible', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Узнай свою профессию'));
    expect(find.text('Узнай свою профессию'), findsOneWidget);
    expect(find.text('Пройти тест'), findsOneWidget);
  });

  testWidgets('"Задание на сегодня" card is present', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Задание на сегодня'));
    expect(find.text('Задание на сегодня'), findsOneWidget);
  });

  testWidgets('task list shows seeded tasks', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Сегодняшние задачи'));
    expect(find.text('Сегодняшние задачи'), findsOneWidget);
    expect(find.text('Пройти урок по математике'), findsOneWidget);
  });

  // ── No stretch-in-scroll guard ───────────────────────────────────────────────

  testWidgets('no stretch-in-scroll — no layout errors after scrolling', (
    tester,
  ) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    expect(
      errors,
      isEmpty,
      reason: 'no layout errors after scroll (stretch-in-scroll guard)',
    );
  });

  // ── Todo CRUD ─────────────────────────────────────────────────────────────────

  testWidgets('add-task sheet opens from + button', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    // The task list card is below the fold — scroll to it first.
    await tester.scrollUntilVisible(
      find.byIcon(Icons.add_circle_outline),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    expect(find.text('Новая задача'), findsWidgets);
    expect(find.text('Сохранить'), findsOneWidget);
  });

  testWidgets('adding a new task updates the list', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    // Scroll the task list card into view before tapping its + button.
    await tester.scrollUntilVisible(
      find.byIcon(Icons.add_circle_outline),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Тест новой задачи');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Тест новой задачи'), findsOneWidget);
  });
}
