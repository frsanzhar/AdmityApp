import 'package:admity/core/env/app_env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exposes the initialized [SupabaseClient] to the rest of the app.
///
/// Throws a clear [StateError] if read before Supabase is configured, so
/// misuse fails loudly during development rather than silently returning a
/// half-initialized client.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!AppEnv.hasSupabase) {
    throw StateError(
      'SupabaseClient was requested but Supabase is not configured. '
      'Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
    );
  }
  return Supabase.instance.client;
});

/// Streams auth state changes (sign-in / sign-out / token refresh).
///
/// Consumed by the router in Step 4 to guard authenticated routes.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});
