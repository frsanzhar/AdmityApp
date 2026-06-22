import 'package:admity/app.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/home/presentation/home_screen.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:admity/features/profile/domain/profile_model.dart';
import 'package:admity/features/splash/presentation/splash_screen.dart';
import 'package:admity/shared/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Wraps [child] in a [MaterialApp] with the Admity theme so
/// [AppTokens] extensions are available without a full router.
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
  testWidgets('app boots to splash without layout errors', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(const ProviderScope(child: AdmityApp()));
    // First frame: splash is visible.
    await tester.pump();

    expect(errors, isEmpty, reason: 'no framework/layout errors on boot');
    expect(find.text('Admity'), findsOneWidget);

    // Drain the pending 1500 ms splash timer so no pending timers remain.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('home screen builds with no framework/layout errors',
      (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(errors, isEmpty, reason: 'no framework/layout errors on HomeScreen');
    expect(find.text('Привет!'), findsOneWidget);
    expect(find.text('Задание на сегодня'), findsOneWidget);
    expect(find.text('Сегодняшние задачи'), findsOneWidget);
  });

  testWidgets('tapping a task opens its edit/delete sheet', (tester) async {
    await tester.pumpWidget(_themed(const HomeScreen()));
    await tester.pumpAndSettle();

    const firstTodoText = 'Пройти урок по математике';
    expect(find.text(firstTodoText), findsOneWidget);

    // Tapping a task row opens the read/edit/delete sheet.
    await tester.ensureVisible(find.text(firstTodoText));
    await tester.pumpAndSettle();
    await tester.tap(find.text(firstTodoText));
    await tester.pumpAndSettle();

    expect(find.text('Удалить задачу'), findsOneWidget);
  });

  testWidgets('splash screen builds without errors', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    // Use a minimal router so context.go('/home') in the timer works.
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    expect(errors, isEmpty,
        reason: 'no framework/layout errors on SplashScreen');
    expect(find.text('Admity'), findsOneWidget);

    // Drain the splash timer so no pending timers remain.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('shell scaffold uses AppBottomNav after Phase 1', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    // Seed a completed-onboarding profile so the splash routes to /home
    // (not /onboarding), and use an in-memory repo so no path_provider /
    // Hive platform channel is hit during the full-app boot.
    final repo = InMemoryProfileRepository();
    await repo.saveProfile(const StudentProfile(onboardingComplete: true));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(repo)],
        child: const AdmityApp(),
      ),
    );
    // Pump past splash (1500 ms timer).
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(errors, isEmpty,
        reason: 'no framework/layout errors after nav to home');
    expect(find.byType(AppBottomNav), findsOneWidget);
    expect(find.text('Главная'), findsWidgets);
  });
}
