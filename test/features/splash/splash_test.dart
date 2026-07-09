import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:admity/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ── Helper ─────────────────────────────────────────────────────────────────────

/// Wraps [SplashScreen] in a minimal GoRouter so that `context.go(...)` inside
/// SplashScreen does not throw "No GoRouter found in context".
///
/// Routes:
///   /             → SplashScreen
///   /auth         → placeholder Scaffold
///   /onboarding   → placeholder Scaffold
///   /home         → placeholder Scaffold
Widget _splashApp({InMemoryProfileRepository? repo}) {
  final effectiveRepo = repo ?? InMemoryProfileRepository();
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('AuthScreen'))),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('OnboardingScreen'))),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('HomeScreen'))),
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

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('SplashScreen builds without layout errors', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_splashApp());
    await tester.pump(); // one frame — renders the wordmark

    expect(errors, isEmpty, reason: 'no layout errors on SplashScreen');

    // Drain the pending navigation timer (disableAnimations path = 1800 ms).
    // pumpAndSettle would hang because GoRouter itself uses timers; instead we
    // pump exactly past the delay so the timer fires and navigation completes.
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(); // settle any follow-on frames

    // Still no errors after navigation.
    expect(errors, isEmpty, reason: 'no errors after navigation timer fires');
  });

  testWidgets('SplashScreen shows Admity wordmark', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_splashApp());
    await tester.pump(); // first frame — wordmark should be visible

    expect(find.text('Admity'), findsOneWidget);

    // Drain the pending timer so no stale timers remain after the test.
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump();

    expect(errors, isEmpty, reason: 'no errors on SplashScreen wordmark test');
  });
}
