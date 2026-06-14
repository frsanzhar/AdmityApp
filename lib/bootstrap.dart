import 'package:admity/app.dart';
import 'package:admity/core/storage/local_store.dart';
import 'package:admity/core/supabase/supabase_bootstrap.dart';
import 'package:admity/core/utils/app_logger.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _logger = AppLogger('Bootstrap');

/// Initializes bindings, storage and the backend, then runs the app inside a
/// [ProviderScope] (the single Riverpod root for the whole tree).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) =>
      _logger.error('FlutterError', details.exception, details.stack);

  final store = await LocalStore.load();
  await initSupabase();

  runApp(
    ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(store)],
      child: const AdmityApp(),
    ),
  );
}
