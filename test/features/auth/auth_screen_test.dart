/// Widget tests for [AuthScreen].
///
/// Covers:
///   1. Google button is absent when AppConfig has no Google / Supabase config
///      (the default in test environments since no `--dart-define` is passed).
///   2. OTP verification step appears after a sign-up call that returns
///      [AuthResult.otpPending].
///   3. [AutofillGroup] is present in the email/password form.
library;

import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/auth/application/auth_providers.dart';
import 'package:admity/features/auth/data/auth_service.dart';
import 'package:admity/features/auth/presentation/auth_screen.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fake AuthService ──────────────────────────────────────────────────────────

/// Returns [AuthResult.otpPending] for sign-up, success for everything else.
class _OtpPendingAuthService extends AuthService {
  // The super constructor's positional parameter is named `_ref` (private),
  // which prevents the `super.ref` super-parameter syntax from a subclass
  // defined in a separate file. Explicit delegation is the only option here.
  // ignore: use_super_parameters
  _OtpPendingAuthService(Ref ref) : super(ref);

  @override
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) async =>
      const AuthResult.otpPending();

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async =>
      const AuthResult.success();

  @override
  Future<AuthResult> continueAsGuest() async => const AuthResult.success();
}

// ── Test helpers ──────────────────────────────────────────────────────────────

/// Wraps [AuthScreen] in a minimal themed [ProviderScope] suitable for testing.
///
/// [authService] optionally overrides the default [AuthService] so tests can
/// inject a fake without touching Supabase or Google Sign-In.
Widget _pumpAuthScreen({
  AuthService Function(Ref)? authService,
}) {
  return ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(InMemoryProfileRepository()),
      if (authService != null)
        authServiceProvider.overrideWith(authService),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [AppTokens.defaults()]),
      home: const AuthScreen(),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Anti-blank-screen guard ──────────────────────────────────────────────────

  testWidgets('AuthScreen builds without layout/framework errors', (
    tester,
  ) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);

    await tester.pumpWidget(_pumpAuthScreen());
    await tester.pumpAndSettle();

    expect(
      errors,
      isEmpty,
      reason: 'no framework/layout errors on AuthScreen build',
    );
  });

  // ── Task 1: Google button hidden ─────────────────────────────────────────────

  testWidgets(
    'Google button is absent when AppConfig has no Google or Supabase config',
    (tester) async {
      // In the test environment String.fromEnvironment returns '' for all
      // keys, so AppConfig.hasGoogle == false && AppConfig.hasSupabase == false.
      // The screen must NOT show the Google button.
      await tester.pumpWidget(_pumpAuthScreen());
      await tester.pumpAndSettle();

      expect(
        find.text('Продолжить с Google'),
        findsNothing,
        reason: 'Google button must be hidden when client IDs are not set',
      );
    },
  );

  testWidgets(
    'Apple button is absent when Supabase is not configured',
    (tester) async {
      await tester.pumpWidget(_pumpAuthScreen());
      await tester.pumpAndSettle();

      expect(
        find.text('Продолжить с Apple'),
        findsNothing,
        reason: 'Apple button must be hidden when Supabase is not configured',
      );
    },
  );

  testWidgets(
    'divider "или" is absent when no social buttons are shown',
    (tester) async {
      await tester.pumpWidget(_pumpAuthScreen());
      await tester.pumpAndSettle();

      expect(
        find.text('или'),
        findsNothing,
        reason: 'divider should be hidden along with social buttons',
      );
    },
  );

  // ── Task 2: OTP step ─────────────────────────────────────────────────────────

  testWidgets(
    'OTP verification step appears after sign-up returns otpPending',
    (tester) async {
      await tester.pumpWidget(
        _pumpAuthScreen(
          authService: _OtpPendingAuthService.new,
        ),
      );
      await tester.pumpAndSettle();

      // Switch to sign-up mode.
      await tester.tap(find.text('Нет аккаунта? Зарегистрироваться'));
      await tester.pumpAndSettle();

      // Fill in email and password.
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'secret123',
      );

      // Tap register — fake service returns otpPending.
      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();

      // OTP step must now be visible.
      expect(
        find.text('Введи код из письма'),
        findsOneWidget,
        reason: 'OTP heading must appear after otpPending result',
      );
      expect(
        find.text('Подтвердить'),
        findsOneWidget,
        reason: 'OTP confirm button must be visible',
      );
      expect(
        find.text('Отправить ещё раз через 60 с'),
        findsOneWidget,
        reason: 'resend countdown must start at 60 s',
      );
    },
  );

  testWidgets(
    'OTP step shows email address in subtitle',
    (tester) async {
      const testEmail = 'hello@admity.kz';

      await tester.pumpWidget(
        _pumpAuthScreen(
          authService: _OtpPendingAuthService.new,
        ),
      );
      await tester.pumpAndSettle();

      // Switch to sign-up mode.
      await tester.tap(find.text('Нет аккаунта? Зарегистрироваться'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        testEmail,
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'pass1234',
      );

      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining(testEmail),
        findsOneWidget,
        reason: 'OTP subtitle must show the email address',
      );
    },
  );

  testWidgets(
    'Back button on OTP step returns to sign-up form',
    (tester) async {
      await tester.pumpWidget(
        _pumpAuthScreen(
          authService: _OtpPendingAuthService.new,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Нет аккаунта? Зарегистрироваться'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'pass1234',
      );
      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();

      // Tap back.
      await tester.tap(find.text('← Изменить email'));
      await tester.pumpAndSettle();

      // Must be back on the normal form.
      expect(find.text('Создать аккаунт'), findsOneWidget);
      expect(find.text('Введи код из письма'), findsNothing);
    },
  );

  // ── Task 3: AutofillGroup ────────────────────────────────────────────────────

  testWidgets(
    'AutofillGroup is present in the email/password form',
    (tester) async {
      await tester.pumpWidget(_pumpAuthScreen());
      await tester.pumpAndSettle();

      expect(
        find.byType(AutofillGroup),
        findsWidgets,
        reason: 'AutofillGroup must wrap the email/password form',
      );
    },
  );

  testWidgets(
    'sign-in shows at least one AutofillGroup',
    (tester) async {
      await tester.pumpWidget(_pumpAuthScreen());
      await tester.pumpAndSettle();

      final groups = tester.widgetList<AutofillGroup>(
        find.byType(AutofillGroup),
      );
      expect(
        groups.isNotEmpty,
        isTrue,
        reason: 'at least one AutofillGroup must exist on auth screen',
      );
    },
  );

  // ── Structural checks ────────────────────────────────────────────────────────

  testWidgets('sign-in heading is visible on first load', (tester) async {
    await tester.pumpWidget(_pumpAuthScreen());
    await tester.pumpAndSettle();

    expect(find.text('Добро пожаловать'), findsOneWidget);
  });

  testWidgets('toggling to sign-up changes heading', (tester) async {
    await tester.pumpWidget(_pumpAuthScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Нет аккаунта? Зарегистрироваться'));
    await tester.pumpAndSettle();

    expect(find.text('Создать аккаунт'), findsOneWidget);
  });

  testWidgets('guest button is always visible', (tester) async {
    await tester.pumpWidget(_pumpAuthScreen());
    await tester.pumpAndSettle();

    expect(find.text('Продолжить как гость'), findsOneWidget);
  });
}
