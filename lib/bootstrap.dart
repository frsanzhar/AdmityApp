import 'dart:async';
import 'package:admity/core/config/app_config.dart';
import 'package:admity/core/notifications/notifications_service.dart';
import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:admity/features/psytests/data/psytests_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps app startup with error handling.
///
/// IMPORTANT (see CLAUDE.md): on this codebase a swallowed *layout* error
/// renders a silent blank screen. So in debug we ALWAYS forward framework
/// errors to the console via [FlutterError.presentError] — never route them
/// somewhere invisible. If you later add a logger here, keep the debug print.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    // Always make it visible in debug so blank screens are debuggable.
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // TODO(admity): forward to crash reporting in release.
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught: $error\n$stack');
    return true;
  };

  // Open the local Hive boxes BEFORE the app reads/writes profile data.
  // Without this, Hive.box(...) throws and saveProfile() silently no-ops —
  // which is why onboarding-collected class/GPA were not persisting.
  try {
    await HiveProfileRepository.init();
  } on Object catch (e) {
    debugPrint('Hive init failed (continuing with in-memory): $e');
  }

  try {
    await HivePsytestsRepository.init();
  } on Object catch (e) {
    debugPrint('Psytests Hive init failed (continuing without): $e');
  }

  // Streak activity box — accumulated in-app seconds per day (yyyy-MM-dd).
  // Opened here so the home streak tracker can read/write it synchronously.
  try {
    await Hive.openBox<int>('admity_activity');
  } on Object catch (e) {
    debugPrint('Activity Hive box init failed (streak not persisted): $e');
  }

  // Initialise local notifications (schedules daily reminders, etc.).
  // Failures are non-fatal — the app degrades gracefully without notifications.
  try {
    await NotificationsService.init();
  } on Object catch (e) {
    debugPrint('NotificationsService init failed (continuing without): $e');
  }

  // Initialise Supabase only when configured (env.json). Without it the app
  // runs fully offline in guest mode — real Google/Apple/email auth and any
  // backend sync simply stay disabled. Failures here are non-fatal.
  if (AppConfig.hasSupabase) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        // The project's anon (publishable) key — `publishableKey` is the
        // current param name; the classic anon JWT is accepted here too.
        publishableKey: AppConfig.supabaseAnonKey,
      );
    } on Object catch (e) {
      debugPrint('Supabase init failed (continuing offline): $e');
    }
  }

  runApp(await builder());
}
