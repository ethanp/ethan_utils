import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'app_log_buffer.dart';

/// Debug logger scoped to a named component.
///
/// Records entries in [appLogBuffer] for all build modes.
///
/// In debug mode, info and fine entries mirror via [developer.log] (no
/// `flutter:` prefix in the IDE). Warnings and errors go to stdout instead,
/// so `flutter run` output — and the workbench run log that captures it —
/// shows them with their stack traces.
///
/// ```dart
/// const _log = ELogger('MyComponent');
/// _log.log('Something happened');
/// _log.warn('Watch out');
/// _log.error('Failed', exception, stackTrace);
/// ```
class const ELogger(final String component) {
  /// When true, [fine] records to [appLogBuffer] and mirrors to the console in
  /// debug mode. Default off — set from `main()` while refining behavior.
  static bool fineEnabled = false;

  void log(String message) =>
      _writeToAppLogAndDebugConsole(level: AppLogLevel.info, message: message);

  void warn(String message, [Object? error, StackTrace? stackTrace]) {
    _writeToAppLogAndDebugConsole(
      level: AppLogLevel.warning,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _writeToAppLogAndDebugConsole(
      level: AppLogLevel.error,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Verbose diagnostics; no-op unless [fineEnabled] is true.
  void fine(String message) {
    if (!fineEnabled) return;
    _writeToAppLogAndDebugConsole(level: AppLogLevel.fine, message: message);
  }

  void _writeToAppLogAndDebugConsole({
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
    if (level == AppLogLevel.warning || level == AppLogLevel.error) {
      debugPrint(logEntry.formattedText);
      return;
    }
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
