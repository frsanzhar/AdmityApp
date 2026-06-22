import 'dart:async';

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

  runApp(await builder());
}
