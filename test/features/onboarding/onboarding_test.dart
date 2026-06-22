/// Widget tests for OnboardingScreen.
library;

import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/onboarding/presentation/onboarding_screen.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/data/profile_repository.dart';
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

  testWidgets('Step progress indicator is present', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('1 / 10'), findsOneWidget);
  });

  testWidgets('Next button advances to step 2', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // Step 0 is welcome — tap Далее.
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();

    expect(find.text('2 / 10'), findsOneWidget);
    expect(find.text('Честный прогноз шансов'), findsOneWidget);
  });

  testWidgets('Back button is not shown on first step', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    // On step 0, there should be no back arrow button (only Next).
    expect(find.text('Далее'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
  });

  testWidgets('Back button appears after advancing', (tester) async {
    await tester.pumpWidget(_themed(const OnboardingScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });
}
