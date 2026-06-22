/// Widget tests for DailyCareerTestScreen.
library;

import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/career/presentation/daily_career_test_screen.dart';
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
  testWidgets('DailyCareerTestScreen builds without layout errors', (
    tester,
  ) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_themed(const DailyCareerTestScreen()));
    await tester.pumpAndSettle();

    expect(
      errors,
      isEmpty,
      reason: 'no framework/layout errors on DailyCareerTestScreen',
    );
  });

  testWidgets('Shows header title', (tester) async {
    await tester.pumpWidget(_themed(const DailyCareerTestScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Узнай свою профессию'), findsOneWidget);
  });

  testWidgets('Shows progress bar and counter', (tester) async {
    await tester.pumpWidget(_themed(const DailyCareerTestScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
  });

  testWidgets('Shows a question with answer options', (tester) async {
    await tester.pumpWidget(_themed(const DailyCareerTestScreen()));
    await tester.pumpAndSettle();

    // At least one answer option should be visible
    // Options are either "Да", "Нет", "Иногда" or "Да", "Нет", "Возможно"
    expect(find.text('Да'), findsOneWidget);
    expect(find.text('Нет'), findsOneWidget);
  });

  testWidgets('Tapping an answer advances to question 2', (tester) async {
    await tester.pumpWidget(_themed(const DailyCareerTestScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Да'));
    // Wait for auto-advance delay (320ms)
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('2 / 5'), findsOneWidget);
  });

  testWidgets('Completing all 5 questions shows the result screen', (
    tester,
  ) async {
    await tester.pumpWidget(_themed(const DailyCareerTestScreen()));
    await tester.pumpAndSettle();

    // Answer all 5 questions by tapping "Да" each time
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Да'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
    }

    expect(find.text('Ты прошёл тест!'), findsOneWidget);
    expect(find.text('На главную'), findsOneWidget);
  });

  testWidgets('Result screen shows top category insight', (tester) async {
    await tester.pumpWidget(_themed(const DailyCareerTestScreen()));
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Да'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
    }

    expect(find.text('Твоя сильная сторона:'), findsOneWidget);
    expect(
      find.text('Возвращайся завтра за новым тестом'),
      findsOneWidget,
    );
  });
}
