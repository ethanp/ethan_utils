import 'package:flutter/foundation.dart';

import 'app_log_buffer.dart';

/// Debug logger scoped to a named component.
///
/// Records entries in [appLogBuffer] for all build modes.
///
/// In debug mode, it also mirrors output to `debugPrint`.
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

  void log(String message) =>
      _record(level: AppLogLevel.info, message: message);

  void warn(String message) =>
      _record(level: AppLogLevel.warning, message: message);

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _record(
      level: AppLogLevel.error,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// No-op. Fine-grained logs are too noisy for terminal output.
  // ignore: avoid_unused_parameters
  void fine(String message) {}

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
    debugPrint(logEntry.formattedText);
  }
}
