import 'dart:developer' as developer;

/// Lightweight, named logger used across the app instead of `print`.
///
/// Wraps `dart:developer`'s `log`, so output is structured and stripped from
/// release builds by the tooling rather than spamming stdout.
class AppLogger {
  /// Creates a logger tagged with [_name] (usually the calling class).
  const AppLogger(this._name);

  final String _name;

  /// Informational message (level 800).
  void info(String message) =>
      developer.log(message, name: _name, level: 800);

  /// Warning message (level 900).
  void warn(String message) =>
      developer.log(message, name: _name, level: 900);

  /// Error message (level 1000) with optional [error] and [stackTrace].
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      developer.log(
        message,
        name: _name,
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
}
