import 'package:flutter/foundation.dart';

/// Debug logger scoped to a named component.
///
/// Formats output as `[HH:mm:ss|Component] message`. No-ops in release mode.
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

  void log(String message) => _print(message);

  void warn(String message) => _print('⚠️ $message');

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _print('🔴 $message');
    if (error != null) _print('  error: $error');
    if (stackTrace != null) _print('  $stackTrace');
  }

  /// No-op. Fine-grained logs are too noisy for terminal output.
  // ignore: avoid_unused_parameters
  void fine(String message) {}

  void _print(String message) {
    if (!kDebugMode) return;
    final now = DateTime.now();
    String pad(int n) => n.toString().padLeft(2, '0');
    final timestamp = '${pad(now.hour)}:${pad(now.minute)}:${pad(now.second)}';
    debugPrint('[$timestamp|$component] $message');
  }
}
