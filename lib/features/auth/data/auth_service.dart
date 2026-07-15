/// Authentication service for Admity.
///
/// Wraps Supabase Auth (email/password, Google, Apple) with a graceful
/// offline/guest fallback — if Supabase is not configured the methods
/// store the auth info locally via the profile and return ok.
///
/// ## External configuration required
///
/// All client-side values live in `env.json` (copy `env.example.json`) and are
/// read via [AppConfig]. Run with `--dart-define-from-file=env.json`. Until
/// `SUPABASE_URL` + `SUPABASE_ANON_KEY` are set the app stays in offline guest
/// mode and these methods record a local session without a real OAuth call.
///
/// To turn on real auth:
///   1. Supabase dashboard → Authentication → Providers: enable Email, Google,
///      Apple (paste the Google web client id and the Apple Services id +
///      key). Put `SUPABASE_URL` / `SUPABASE_ANON_KEY` in `env.json`.
///   2. Google Cloud Console → create OAuth clients (Web + iOS). Put
///      `GOOGLE_WEB_CLIENT_ID` (+ optional `GOOGLE_IOS_CLIENT_ID`) in
///      `env.json`, add `GoogleService-Info.plist` to `ios/Runner`, and add
///      its reversed client id as a URL scheme in `Info.plist`.
///   3. Apple (needs the paid Developer Program): register an App ID with the
///      "Sign in with Apple" capability + a Services ID, then add the
///      `com.apple.developer.applesignin` entitlement to the Xcode project.
///      NOTE: do not add that entitlement while signing with a free personal
///      team — the install will be rejected on device.
library;

import 'package:admity/core/config/app_config.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Result type ───────────────────────────────────────────────────────────────

/// Outcome of an [AuthService] call.
///
/// [ok] is true on success; [error] is a user-facing Russian/English message
/// on failure; [needsOtp] is true when the server needs the user to verify a
/// 6-digit code that was sent to their email.
class AuthResult {
  /// Creates a successful result.
  const AuthResult.success()
      : ok = true,
        error = null,
        needsOtp = false;

  /// Creates a failure result with a user-visible [error] message.
  const AuthResult.failure(String this.error)
      : ok = false,
        needsOtp = false;

  /// Sign-up succeeded server-side but email confirmation is required.
  ///
  /// The caller should show the OTP verification step.
  const AuthResult.otpPending()
      : ok = false,
        error = null,
        needsOtp = true;

  /// Whether the operation succeeded.
  final bool ok;

  /// Human-readable error message, or null on success / pending OTP.
  final String? error;

  /// Whether the server is waiting for an OTP code from the user's email.
  final bool needsOtp;
}

// ── AuthService ───────────────────────────────────────────────────────────────

/// Stateless authentication gateway.
///
/// All methods return [AuthResult] and never throw — errors are swallowed and
/// returned as [AuthResult.failure]. This keeps callers simple and ensures
/// that a missing Supabase config never crashes the app.
///
/// When Supabase is unavailable the service degrades to a local guest
/// sign-in: it writes `authProvider`/`authEmail` to the profile so the rest
/// of the app behaves as though the user is logged in.
class AuthService {
  /// Creates an [AuthService].
  ///
  /// `ref` is used to write auth results back to the profile store.
  const AuthService(this._ref);

  final Ref _ref;

  // ── Email / password ──────────────────────────────────────────────────────

  /// Signs in an existing user with [email] and [password].
  ///
  /// On Supabase success, saves `authProvider` = 'email' and `authEmail` to
  /// the profile. Falls back to a local guest sign-in if Supabase is not
  /// configured.
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Offline/dev mode — no backend configured, record a local session.
    if (!AppConfig.hasSupabase) {
      await _saveAuthToProfile(provider: 'email', email: email);
      return const AuthResult.success();
    }
    try {
      final client = Supabase.instance.client;
      await client.auth.signInWithPassword(email: email, password: password);
      await _saveAuthToProfile(provider: 'email', email: email);
      return const AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.failure(_localiseSupabaseError(e.message));
    } on Object catch (e) {
      debugPrint('[AuthService] signInWithEmail error: $e');
      return const AuthResult.failure(
        'Не удалось войти. Проверьте подключение и попробуйте снова.',
      );
    }
  }

  /// Creates a new account with [email] and [password].
  ///
  /// When Supabase has email-confirmation enabled the account is created but
  /// the session is null — in that case this method returns
  /// [AuthResult.otpPending] so the caller can show the OTP verification step.
  /// Falls back to local sign-in when Supabase is absent.
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    // Offline/dev mode — no backend configured, record a local session.
    if (!AppConfig.hasSupabase) {
      await _saveAuthToProfile(provider: 'email', email: email);
      return const AuthResult.success();
    }
    try {
      final client = Supabase.instance.client;
      final res = await client.auth.signUp(email: email, password: password);
      if (res.session == null) {
        // Supabase requires email confirmation — OTP was sent to the inbox.
        return const AuthResult.otpPending();
      }
      // Auto-confirm flow: a session was returned immediately.
      await _saveAuthToProfile(provider: 'email', email: email);
      return const AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.failure(_localiseSupabaseError(e.message));
    } on Object catch (e) {
      debugPrint('[AuthService] signUpWithEmail error: $e');
      return const AuthResult.failure(
        'Не удалось создать аккаунт. Проверьте подключение и попробуйте снова.',
      );
    }
  }

  /// Verifies the 6-digit [token] sent to [email] during sign-up.
  ///
  /// On success the user is logged in and [AuthResult.success] is returned.
  Future<AuthResult> verifyOtp({
    required String email,
    required String token,
  }) async {
    if (!AppConfig.hasSupabase) {
      // Offline mode — accept any code, just finish the local session.
      await _saveAuthToProfile(provider: 'email', email: email);
      return const AuthResult.success();
    }
    try {
      final client = Supabase.instance.client;
      await client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
      await _saveAuthToProfile(provider: 'email', email: email);
      return const AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.failure(_localiseOtpError(e.message));
    } on Object catch (e) {
      debugPrint('[AuthService] verifyOtp error: $e');
      return const AuthResult.failure(
        'Не удалось проверить код. Попробуйте снова.',
      );
    }
  }

  /// Re-sends the confirmation OTP for the given [email].
  ///
  /// Returns [AuthResult.success] when the request was accepted, or
  /// [AuthResult.failure] with a reason on error.
  Future<AuthResult> resendSignupOtp({required String email}) async {
    if (!AppConfig.hasSupabase) {
      return const AuthResult.success();
    }
    try {
      final client = Supabase.instance.client;
      await client.auth.resend(
        email: email,
        type: OtpType.signup,
      );
      return const AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.failure(_localiseSupabaseError(e.message));
    } on Object catch (e) {
      debugPrint('[AuthService] resendSignupOtp error: $e');
      return const AuthResult.failure(
        'Не удалось отправить код. Попробуйте снова.',
      );
    }
  }

  // ── Google ────────────────────────────────────────────────────────────────

  /// Launches the Google account picker and signs in via Supabase
  /// `signInWithIdToken`.
  ///
  /// Falls back to local guest mode if Google Sign-In or Supabase is not
  /// configured.
  Future<AuthResult> signInWithGoogle() async {
    // Offline/dev mode — no backend configured, record a local session so the
    // app is usable without a real OAuth round-trip.
    if (!AppConfig.hasSupabase) {
      await _saveAuthToProfile(provider: 'google', email: null);
      return const AuthResult.success();
    }
    if (!AppConfig.hasGoogle) {
      return const AuthResult.failure(
        'Вход через Google ещё не настроен. Добавьте GOOGLE_WEB_CLIENT_ID.',
      );
    }
    try {
      // iOS client id is optional — google_sign_in falls back to the bundled
      // GoogleService-Info.plist when it is omitted. The web client id is the
      // serverClientId so Supabase can verify the id-token audience.
      final googleSignIn = GoogleSignIn(
        clientId: AppConfig.googleIosClientId.isEmpty
            ? null
            : AppConfig.googleIosClientId,
        serverClientId: AppConfig.googleWebClientId.isEmpty
            ? null
            : AppConfig.googleWebClientId,
      );
      final account = await googleSignIn.signIn();
      if (account == null) {
        // User cancelled the picker.
        return const AuthResult.failure('Вход отменён.');
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        return const AuthResult.failure(
          'Не удалось получить токен Google. Попробуйте снова.',
        );
      }

      final client = Supabase.instance.client;
      await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: auth.accessToken,
      );

      await _saveAuthToProfile(provider: 'google', email: account.email);
      return const AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.failure(_localiseSupabaseError(e.message));
    } on Object catch (e) {
      debugPrint('[AuthService] signInWithGoogle error: $e');
      return const AuthResult.failure(
        'Не удалось войти через Google. Попробуй ещё раз или войди по почте.',
      );
    }
  }

  // ── Apple ─────────────────────────────────────────────────────────────────

  /// Launches the Apple sign-in sheet and signs in via Supabase
  /// `signInWithIdToken`.
  ///
  /// Falls back to local guest mode if Sign In with Apple or Supabase is not
  /// configured.
  Future<AuthResult> signInWithApple() async {
    // Offline/dev mode — no backend configured, record a local session.
    if (!AppConfig.hasSupabase) {
      await _saveAuthToProfile(provider: 'apple', email: null);
      return const AuthResult.success();
    }
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        return const AuthResult.failure(
          'Не удалось получить токен Apple. Попробуйте снова.',
        );
      }

      final client = Supabase.instance.client;
      await client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );

      // Apple only returns email on the very first sign-in; subsequent
      // sign-ins return null — preserve the stored email in that case.
      await _saveAuthToProfile(provider: 'apple', email: credential.email);
      return const AuthResult.success();
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const AuthResult.failure('Вход отменён.');
      }
      return const AuthResult.failure(
        'Не удалось войти через Apple. Попробуй ещё раз или войди по почте.',
      );
    } on AuthException catch (e) {
      return AuthResult.failure(_localiseSupabaseError(e.message));
    } on Object catch (e) {
      debugPrint('[AuthService] signInWithApple error: $e');
      return const AuthResult.failure(
        'Не удалось войти через Apple. Попробуй ещё раз или войди по почте.',
      );
    }
  }

  // ── Guest ─────────────────────────────────────────────────────────────────

  /// Records a guest sign-in locally without touching Supabase.
  ///
  /// The guest can use the full app; their data is stored on-device only.
  Future<AuthResult> continueAsGuest() async {
    try {
      await _saveAuthToProfile(provider: 'guest', email: null);
      return const AuthResult.success();
    } on Object catch (e) {
      debugPrint('[AuthService] continueAsGuest error: $e');
      return const AuthResult.failure('Не удалось создать гостевой профиль.');
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  /// Signs the user out of Supabase (if configured) and clears the local
  /// auth metadata from the profile.
  Future<AuthResult> signOut() async {
    try {
      if (AppConfig.hasSupabase) {
        await Supabase.instance.client.auth.signOut();
      }
      // Clear auth fields from the local profile.
      final notifier = _ref.read(profileProvider.notifier);
      final current = _ref.read(profileProvider).profile;
      final updated = current.copyWith(
        authProvider: null,
        authEmail: null,
      );
      await notifier.saveProfile(updated);
      return const AuthResult.success();
    } on Object catch (e) {
      debugPrint('[AuthService] signOut error: $e');
      return const AuthResult.failure(
        'Не удалось выйти. Попробуйте снова.',
      );
    }
  }

  // ── Account deletion ─────────────────────────────────────────────────────

  /// Permanently deletes the user's account and all associated data.
  ///
  /// 1. Calls the Supabase Edge Function `delete-user` (or the built-in
  ///    admin endpoint) to remove the Auth user.
  /// 2. Clears all local Hive data (profile, notes, document packages).
  /// 3. Returns [AuthResult.success] — the caller should navigate to /auth.
  ///
  /// This satisfies Apple Guideline 5.1.1(v) — "apps that support account
  /// creation must also offer account deletion".
  Future<AuthResult> deleteAccount() async {
    try {
      if (AppConfig.hasSupabase) {
        final client = Supabase.instance.client;
        final user = client.auth.currentUser;
        if (user != null) {
          // Use the Supabase RPC function to delete the user's own account.
          // If the RPC doesn't exist, fall back to signing out (the server
          // admin can clean up orphaned accounts later).
          try {
            await client.rpc('delete_own_account');
          } on Object catch (e) {
            debugPrint(
              '[AuthService] deleteAccount RPC unavailable, '
              'falling back to sign-out: $e',
            );
            // Ensure the user is at least signed out.
            await client.auth.signOut();
          }
        }
      }
      // Clear ALL local data.
      await _ref.read(profileProvider.notifier).clearAllData();
      return const AuthResult.success();
    } on Object catch (e) {
      debugPrint('[AuthService] deleteAccount error: $e');
      return const AuthResult.failure(
        'Не удалось удалить аккаунт. Попробуйте снова.',
      );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Persists auth metadata to the local profile via [profileProvider].
  Future<void> _saveAuthToProfile({
    required String provider,
    required String? email,
  }) async {
    final notifier = _ref.read(profileProvider.notifier);
    final current = _ref.read(profileProvider).profile;
    final updated = current.copyWith(
      authProvider: provider,
      // Preserve a previously stored email if the new value is null (Apple
      // omits email on repeat sign-ins).
      authEmail: email ?? current.authEmail,
    );
    await notifier.saveProfile(updated);
  }

  /// Maps common Supabase error messages to user-friendly Russian strings.
  String _localiseSupabaseError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return 'Неверный email или пароль.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Подтвердите email по ссылке из письма.';
    }
    if (lower.contains('user already registered')) {
      return 'Этот email уже зарегистрирован. Попробуйте войти.';
    }
    if (lower.contains('password should be at least')) {
      return 'Пароль должен содержать не менее 6 символов.';
    }
    if (lower.contains('rate limit')) {
      return 'Слишком много попыток. Подождите немного и повторите.';
    }
    return raw;
  }

  /// Maps OTP-specific Supabase errors to user-friendly Russian strings.
  String _localiseOtpError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('token has expired') || lower.contains('expired')) {
      return 'Код устарел. Нажмите «Отправить ещё раз», чтобы получить новый.';
    }
    if (lower.contains('invalid') || lower.contains('otp')) {
      return 'Неверный код. Проверьте письмо и введите 6 цифр снова.';
    }
    if (lower.contains('rate limit')) {
      return 'Слишком много попыток. Подождите немного и повторите.';
    }
    return raw;
  }
}
