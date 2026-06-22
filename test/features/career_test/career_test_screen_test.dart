/// Widget tests for CareerTestScreen.
library;

import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:admity/features/profile/presentation/career_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _themed(Widget child, {InMemoryProfileRepository? repo}) {
  final effectiveRepo = repo ?? InMemoryProfileRepository();
  return ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(effectiveRepo),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [AppTokens.defaults()]),
      home: child,
    ),
  );
}

void main() {
  testWidgets('CareerTestScreen builds without layout errors', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_themed(const CareerTestScreen()));
    await tester.pumpAndSettle();

    expect(
      errors,
      isEmpty,
      reason: 'no framework/layout errors on CareerTestScreen',
    );
  });

  testWidgets('Shows warning card with time estimate', (tester) async {
    await tester.pumpWidget(_themed(const CareerTestScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('10–15 минут'), findsOneWidget);
  });

  testWidgets('Shows first question', (tester) async {
    await tester.pumpWidget(_themed(const CareerTestScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Вопрос 1'), findsOneWidget);
    expect(
      find.textContaining('собирать и чинить вещи'),
      findsOneWidget,
    );
  });

  testWidgets('Shows answer chips Нет / Нейтрально / Да', (tester) async {
    await tester.pumpWidget(_themed(const CareerTestScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Нет'), findsOneWidget);
    expect(find.text('Нейтрально'), findsOneWidget);
    expect(find.text('Да'), findsOneWidget);
  });

  testWidgets('Progress bar is visible', (tester) async {
    await tester.pumpWidget(_themed(const CareerTestScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsWidgets);
    expect(find.text('1 / 30'), findsOneWidget);
  });

  testWidgets('Tapping Да advances to question 2', (tester) async {
    await tester.pumpWidget(_themed(const CareerTestScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Да'));
    // The 200ms delay before auto-advance
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Вопрос 2'), findsOneWidget);
  });
}
