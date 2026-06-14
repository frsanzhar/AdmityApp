/// Compile-time environment configuration.
///
/// Values are injected with `--dart-define` (or `--dart-define-from-file`).
/// No secrets are ever hardcoded; the Supabase anon key is public by design
/// and protected at the data layer by Row-Level Security. The LLM API key is
/// never present in the client — Eraly runs server-side in an Edge Function.
abstract final class AppEnv {
  /// Supabase project URL, e.g. `https://xxxxxxxx.supabase.co`.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anon (public) key. Safe to ship; RLS guards every row.
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Whether Supabase credentials are present. When `false`, the app still
  /// runs (offline-light) so the UI can be built before the backend exists.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
