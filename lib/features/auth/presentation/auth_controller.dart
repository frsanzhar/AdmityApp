import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:admity/core/env/app_env.dart';
import 'package:admity/core/utils/app_logger.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _logger = AppLogger('AuthController');

/// Which step of the Gmail one-time-code flow the screen should render.
enum AuthStep {
  /// Pick a provider (Apple / Gmail) — nothing entered yet.
  chooseProvider,

  /// Gmail chosen: enter the email to receive a code.
  enterEmail,

  /// Code sent: enter the 6-digit code from the email.
  enterCode,

  /// Verified and a session is active.
  signedIn,
}

/// Immutable UI state for the auth flow.
///
/// Drives a single polished screen across provider choice, email entry, code
/// entry and the signed-in confirmation, plus transient loading / error text.
class AuthState {
  /// Creates an [AuthState]; defaults to the provider-choice step, idle.
  const AuthState({
    this.step = AuthStep.chooseProvider,
    this.email = '',
    this.busy = false,
    this.error,
    this.info,
  });

  /// Current step of the flow.
  final AuthStep step;

  /// Email captured for the Gmail one-time-code path.
  final String email;

  /// Whether a network call is in flight (disables inputs, shows spinners).
  final bool busy;

  /// Friendly, Russian error message to surface, or `null`.
  final String? error;

  /// Friendly, Russian info message (e.g. "code sent"), or `null`.
  final String? info;

  /// Returns a copy with the given fields overridden. Pass [clearError] /
  /// [clearInfo] to reset those messages (they are not nullable via copy).
  AuthState copyWith({
    AuthStep? step,
    String? email,
    bool? busy,
    String? error,
    String? info,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return AuthState(
      step: step ?? this.step,
      email: email ?? this.email,
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      info: clearInfo ? null : (info ?? this.info),
    );
  }
}

/// Orchestrates registration via Apple and via Gmail-with-one-time-code.
///
/// Apple: fetches an Apple ID credential (with a hashed nonce) and exchanges
/// it for a Supabase session via `signInWithIdToken`. Gmail: requests a code
/// with `signInWithOtp`, then verifies it with `verifyOTP`. Supabase persists
/// the resulting session itself, so callers only need to react to success.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  SupabaseClient get _client => Supabase.instance.client;

  /// Resets back to the provider-choice step (e.g. user tapped "back").
  void reset() => state = const AuthState();

  /// Reveals the Gmail email field.
  void chooseGmail() => state = state.copyWith(
        step: AuthStep.enterEmail,
        clearError: true,
        clearInfo: true,
      );

  /// Keeps the typed email in state so a rebuild never loses it.
  void setEmail(String value) => state = state.copyWith(email: value);

  /// Sends a one-time code to the stored email via Supabase email OTP.
  ///
  /// On success advances to the code-entry step. No-op (with a friendly
  /// message) when Supabase is not configured.
  Future<void> sendCode() async {
    if (!_ensureConfigured()) return;
    final email = state.email.trim();
    if (!_looksLikeEmail(email)) {
      state = state.copyWith(error: 'Введите корректный email.');
      return;
    }
    state = state.copyWith(busy: true, clearError: true, clearInfo: true);
    try {
      await _client.auth.signInWithOtp(email: email);
      state = state.copyWith(
        step: AuthStep.enterCode,
        busy: false,
        info: 'Мы отправили 6-значный код на $email.',
      );
    } on AuthException catch (e) {
      _logger.warn('signInWithOtp failed: ${e.message}');
      state = state.copyWith(busy: false, error: _friendly(e));
    } on Object catch (e) {
      _logger.error('signInWithOtp error', e);
      state = state.copyWith(busy: false, error: _genericError);
    }
  }

  /// Verifies the entered 6-digit [code] against the email OTP.
  ///
  /// On success Supabase stores the session and the step becomes
  /// [AuthStep.signedIn].
  Future<void> verifyCode(String code) async {
    if (!_ensureConfigured()) return;
    final token = code.trim();
    if (token.length < 6) {
      state = state.copyWith(error: 'Код состоит из 6 цифр.');
      return;
    }
    state = state.copyWith(busy: true, clearError: true, clearInfo: true);
    try {
      await _client.auth.verifyOTP(
        email: state.email.trim(),
        token: token,
        type: OtpType.email,
      );
      state = state.copyWith(step: AuthStep.signedIn, busy: false);
    } on AuthException catch (e) {
      _logger.warn('verifyOTP failed: ${e.message}');
      state = state.copyWith(busy: false, error: _friendly(e));
    } on Object catch (e) {
      _logger.error('verifyOTP error', e);
      state = state.copyWith(busy: false, error: _genericError);
    }
  }

  /// Re-requests a fresh code for the same email.
  Future<void> resendCode() => sendCode();

  /// Runs the Sign in with Apple flow and exchanges the credential for a
  /// Supabase session. Apple has already verified the user, so the session is
  /// saved immediately on success.
  Future<void> signInWithApple() async {
    if (!_ensureConfigured()) return;
    state = state.copyWith(busy: true, clearError: true, clearInfo: true);
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        state = state.copyWith(
          busy: false,
          error: 'Apple не вернул токен. Попробуйте ещё раз.',
        );
        return;
      }

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      state = state.copyWith(step: AuthStep.signedIn, busy: false);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        state = state.copyWith(busy: false);
        return;
      }
      _logger.warn('Apple sign-in failed: ${e.message}');
      state = state.copyWith(
        busy: false,
        error: 'Не удалось войти через Apple. Попробуйте ещё раз.',
      );
    } on AuthException catch (e) {
      _logger.warn('Apple signInWithIdToken failed: ${e.message}');
      state = state.copyWith(busy: false, error: _friendly(e));
    } on Object catch (e) {
      _logger.error('Apple sign-in error', e);
      state = state.copyWith(busy: false, error: _genericError);
    }
  }

  bool _ensureConfigured() {
    if (AppEnv.hasSupabase) return true;
    state = state.copyWith(
      error: 'Подключите Supabase, чтобы войти. Сейчас можно '
          'продолжить как гость — всё работает офлайн.',
    );
    return false;
  }

  static const _genericError =
      'Что-то пошло не так. Проверьте соединение и попробуйте снова.';

  String _friendly(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('expired')) {
      return 'Код истёк. Запросите новый.';
    }
    if (msg.contains('invalid') || msg.contains('token')) {
      return 'Неверный код. Проверьте и попробуйте снова.';
    }
    if (msg.contains('rate') || msg.contains('limit')) {
      return 'Слишком много попыток. Подождите минуту.';
    }
    return _genericError;
  }

  bool _looksLikeEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

  String _generateNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}

/// Provides the [AuthController] and its [AuthState] to the auth screen.
final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Streams the current Supabase auth [User], or `null` when signed out or when
/// Supabase is not configured (offline-light). Lets the UI show a sign-in entry
/// vs the signed-in account.
final authUserProvider = StreamProvider<User?>((ref) async* {
  if (!AppEnv.hasSupabase) {
    yield null;
    return;
  }
  final client = Supabase.instance.client;
  yield client.auth.currentUser;
  await for (final event in client.auth.onAuthStateChange) {
    yield event.session?.user;
  }
});

/// Whether Apple sign-in should be offered (iOS / macOS only).
///
/// Wrapped in a getter so widget code stays free of `dart:io` imports and the
/// Android build never references the Apple button.
final appleAuthAvailableProvider = Provider<bool>((ref) {
  if (!AppEnv.hasSupabase) return false;
  // `Platform` is from dart:io and throws on Flutter web — guard first so
  // opening the auth screen on the web target doesn't crash at build time.
  if (kIsWeb) return false;
  return Platform.isIOS || Platform.isMacOS;
});
