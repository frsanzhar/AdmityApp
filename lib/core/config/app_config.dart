/// Compile-time app configuration, read from `--dart-define` values (typically
/// supplied via `--dart-define-from-file=env.json`).
///
/// Nothing here is required for the app to run: with no values the app stays in
/// fully-offline guest mode. Provide the keys (see `env.example.json`) to turn
/// on real Supabase auth and Google/Apple sign-in.
library;

/// Read-only accessors for the values baked in at build time.
class AppConfig {
  const AppConfig._();

  /// Supabase project URL, e.g. `https://xxxx.supabase.co`.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anonymous (publishable) key.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Google OAuth **Web** client id (`...apps.googleusercontent.com`).
  ///
  /// Used as `serverClientId` so Supabase can verify the Google id-token
  /// audience. Required for Google sign-in to authenticate against Supabase.
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  /// Google OAuth **iOS** client id (`...apps.googleusercontent.com`).
  ///
  /// Optional — if omitted, `google_sign_in` reads it from the bundled
  /// `GoogleService-Info.plist` on iOS instead.
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );

  /// True when Supabase is configured — gates real auth and backend sync.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// True when at least one Google client id is configured.
  static bool get hasGoogle =>
      googleWebClientId.isNotEmpty || googleIosClientId.isNotEmpty;
}
