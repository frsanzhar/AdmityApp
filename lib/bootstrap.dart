import 'dart:async';

import 'package:admity/features/profile/data/profile_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  runApp(await builder());
}
