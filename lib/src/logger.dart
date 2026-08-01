import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'app_log_buffer.dart';

/// Debug logger scoped to a named component.
///
/// Records entries in [appLogBuffer] for all build modes.
///
/// In debug mode, it also mirrors output via [developer.log] (avoids the
/// `flutter:` prefix that `debugPrint` / `print` get from Flutter tooling).
///
/// ```dart
/// const _log = ELogger('MyComponent');
/// _log.log('Something happened');
/// _log.warn('Watch out');
/// _log.error('Failed', exception, stackTrace);
/// ```
class ELogger {
  final String component;

  const ELogger(this.component);

  /// When true, [fine] records to [appLogBuffer] and mirrors to the console in
  /// debug mode. Default off — set from `main()` while refining behavior.
  static bool fineEnabled = false;

  void log(String message) =>
      _record(level: AppLogLevel.info, message: message);

  void warn(String message, [Object? error, StackTrace? stackTrace]) {
    _record(
      level: AppLogLevel.warning,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _record(
      level: AppLogLevel.error,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Verbose diagnostics; no-op unless [fineEnabled] is true.
  void fine(String message) {
    if (!fineEnabled) return;
    _record(level: AppLogLevel.fine, message: message);
  }

  void _record({
    required AppLogLevel level,
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final logEntry = appLogBuffer.record(
      component: component,
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
    if (!kDebugMode) return;
    developer.log(
      logEntry.formattedText,
      name: component,
      level: _developerLogLevel(level),
    );
  }

  static int _developerLogLevel(AppLogLevel level) => switch (level) {
        AppLogLevel.fine => 500,
        AppLogLevel.info => 800,
        AppLogLevel.warning => 900,
        AppLogLevel.error => 1000,
      };
}
