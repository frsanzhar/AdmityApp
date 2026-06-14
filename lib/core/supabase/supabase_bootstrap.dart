import 'package:admity/core/env/app_env.dart';
import 'package:admity/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _logger = AppLogger('SupabaseBootstrap');

/// Initializes Supabase when credentials are configured.
///
/// Safe to call while unconfigured: the app then runs without a backend,
/// which is useful for early UI work before Supabase is connected. Once
/// [AppEnv.hasSupabase] is true, `Supabase.instance` is ready everywhere.
Future<void> initSupabase() async {
  if (!AppEnv.hasSupabase) {
    _logger.warn(
      'Supabase not configured (SUPABASE_URL / SUPABASE_ANON_KEY missing). '
      'Running offline-light without a backend.',
    );
    return;
  }

  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    // `anonKey` is being superseded by `publishableKey` in supabase_flutter,
    // but the JWT anon key remains valid and is what most existing projects
    // use. Migrate to publishable keys when rotating credentials.
    // ignore: deprecated_member_use
    anonKey: AppEnv.supabaseAnonKey,
  );
  _logger.info('Supabase initialized.');
}
