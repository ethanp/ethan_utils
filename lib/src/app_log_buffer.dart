import 'dart:collection';

import 'package:flutter/foundation.dart';

enum AppLogLevel({
  /// Stable tag used in [AppLogEntry.formattedText] and filterable via regex.
  required final String tag,
}) {
  info(tag: 'INFO'),
  warning(tag: 'WARN'),
  error(tag: 'ERROR'),
  fine(tag: 'FINE'),
}

@immutable
class const AppLogEntry({
  required final DateTime timestamp,
  required final String component,
  required final AppLogLevel level,
  required final String message,
  final Object? error,
  final StackTrace? stackTrace,
}) {
  String get formattedText {
    final logMessageBuffer = StringBuffer(_bracketedClockTagAndComponent())
      ..write(message);

    if (error != null) {
      logMessageBuffer.write('\n  error: $error');
    }
    if (stackTrace != null) {
      logMessageBuffer.write('\n  $stackTrace');
    }

    return logMessageBuffer.toString();
  }

  String _bracketedClockTagAndComponent() =>
      '[${_hhMmSsWithCentiseconds()}|${level.tag}|$component] ';

  String _hhMmSsWithCentiseconds() {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    final centiseconds = (timestamp.millisecond ~/ 10).toString().padLeft(
      2,
      '0',
    );
    return '$hour:$minute:$second.$centiseconds';
  }
}

class AppLogBuffer({final int maxEntries = 1000, DateTime Function()? clock})
    extends ChangeNotifier {
  this : assert(maxEntries > 0);

  final DateTime Function() _clock = clock ?? DateTime.now;
  final List<AppLogEntry> _entries = [];

  UnmodifiableListView<AppLogEntry> get entries =>
      UnmodifiableListView(_entries);

  AppLogEntry record({
    required String component,
    required AppLogLevel level,
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final appLogEntry = AppLogEntry(
      timestamp: _clock(),
      component: component,
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
    _append(appLogEntry);
    return appLogEntry;
  }

  void capturePrintLine(String message, {String component = 'DartPrint'}) {
    if (_looksLikeStructuredAppLogLine(message)) return;
    record(component: component, level: AppLogLevel.info, message: message);
  }

  void captureDebugPrintLine(String message, {String component = 'Flutter'}) {
    if (_looksLikeStructuredAppLogLine(message)) return;
    record(component: component, level: AppLogLevel.info, message: message);
  }

  void clear() {
    if (_entries.isEmpty) return;
    _entries.clear();
    notifyListeners();
  }

  void _append(AppLogEntry appLogEntry) {
    _entries.add(appLogEntry);
    _dropOldestPastMaxEntries();
    notifyListeners();
  }

  void _dropOldestPastMaxEntries() {
    if (_entries.length <= maxEntries) return;
    final overflowEntryCount = _entries.length - maxEntries;
    _entries.removeRange(0, overflowEntryCount);
  }

  bool _looksLikeStructuredAppLogLine(String message) =>
      RegExp(r'^\[\d{2}:\d{2}:\d{2}\.\d{2}\|').hasMatch(message);
}

final appLogBuffer = AppLogBuffer();
