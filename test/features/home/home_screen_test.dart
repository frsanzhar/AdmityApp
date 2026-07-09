import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/home/presentation/home_screen.dart';
import 'package:admity/shared/widgets/streak_badge.dart';
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

    // A fresh account has no earned streak yet, so the card invites the user
    // to start one rather than showing a fabricated day count.
    expect(find.text('Начни свою серию!'), findsOneWidget);
    // Day labels appear in both the streak row and the calendar weekday header.
    expect(find.text('Пн'), findsWidgets);
    expect(find.text('Вс'), findsWidgets);
  });

  testWidgets('streak badge hidden for fresh account', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    // No activity data → streak count is 0 → badge is not rendered.
    expect(find.byType(StreakBadge), findsNothing);
  });

  testWidgets('streak badge appears when provider has consecutive days', (
    tester,
  ) async {
    final today = DateTime.now();
    final todayKey =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activitySecondsProvider.overrideWith(
            () => _StubActivitySecondsNotifier({todayKey: 300}),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [AppTokens.defaults()]),
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StreakBadge), findsOneWidget);
  });

  testWidgets('tapping a streak day shows its state label', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Пн').first);
    await tester.pumpAndSettle();

    expect(find.text('Ещё не завершён'), findsOneWidget);

    await tester.tap(find.text('Чт').first);
    await tester.pumpAndSettle();

    expect(find.text('Ещё не завершён'), findsOneWidget);
  });

  testWidgets('calendar card is visible', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_left), findsWidgets);
    expect(find.byIcon(Icons.chevron_right), findsWidgets);
    expect(find.text('Пн'), findsWidgets);
  });

  testWidgets('"Событие" add button is present in calendar', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Событие'), findsOneWidget);
  });

  testWidgets('"Задача" add button is present in calendar', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Задача'), findsOneWidget);
  });

  testWidgets('"Задание на сегодня" card is absent', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Задание на сегодня'), findsNothing);
  });

  testWidgets('career test card is visible', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Узнай свою профессию'));
    expect(find.text('Узнай свою профессию'), findsOneWidget);
    expect(find.text('Пройти тест'), findsOneWidget);
  });

  testWidgets('fresh account has no default tasks in calendar', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    // No seeded todos — the day agenda shows the empty-state message.
    // Пустой день больше не показывает заглушку — только кнопки.
    expect(find.text('Событий и задач нет.'), findsNothing);
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

  // ── Unified day agenda CRUD ───────────────────────────────────────────────────

  testWidgets('add-task sheet opens from "Задача" button', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Задача'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Задача'));
    await tester.pumpAndSettle();

    expect(find.text('Новая задача'), findsWidgets);
    expect(find.text('Сохранить'), findsOneWidget);
  });

  testWidgets('adding a new task shows it in the calendar day agenda', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Задача'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Задача'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Тест новой задачи');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    // Task is in today's agenda (today is the default selected date).
    expect(find.text('Тест новой задачи'), findsOneWidget);
  });
}

// ── Test helpers ─────────────────────────────────────────────────────────────

/// Stub notifier that pre-seeds [ActivitySecondsNotifier] with known data.
class _StubActivitySecondsNotifier extends ActivitySecondsNotifier {
  _StubActivitySecondsNotifier(this._seed);
  final Map<String, int> _seed;

  @override
  Map<String, int> build() => Map<String, int>.unmodifiable(_seed);
}
