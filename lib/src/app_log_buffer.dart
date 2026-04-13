import 'dart:collection';

import 'package:flutter/foundation.dart';

enum AppLogLevel { info, warning, error, fine }

@immutable
class AppLogEntry {
  const AppLogEntry({
    required this.timestamp,
    required this.component,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final DateTime timestamp;
  final String component;
  final AppLogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  String get formattedText {
    final logMessageBuffer = StringBuffer(_logLinePrefix())
      ..write(_formattedMessageBody());

    if (error != null) {
      logMessageBuffer.write('\n  error: $error');
    }
    if (stackTrace != null) {
      logMessageBuffer.write('\n  $stackTrace');
    }

    return logMessageBuffer.toString();
  }

  String _logLinePrefix() => '[${_formattedTimestamp()}|$component] ';

  String _formattedTimestamp() {
    String pad(int value) => value.toString().padLeft(2, '0');
    final centiseconds =
        (timestamp.millisecond ~/ 10).toString().padLeft(2, '0');
    return '${pad(timestamp.hour)}:${pad(timestamp.minute)}:'
        '${pad(timestamp.second)}.$centiseconds';
  }

  String _formattedMessageBody() => switch (level) {
        AppLogLevel.info => message,
        AppLogLevel.warning => 'WARNING: $message',
        AppLogLevel.error => 'ERROR: $message',
        AppLogLevel.fine => 'FINE: $message',
      };
}

class AppLogBuffer extends ChangeNotifier {
  AppLogBuffer({
    this.maxEntries = 1000,
    DateTime Function()? clock,
  })  : assert(maxEntries > 0),
        _clock = clock ?? DateTime.now;

  final int maxEntries;
  final DateTime Function() _clock;
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
    record(
      component: component,
      level: AppLogLevel.info,
      message: message,
    );
  }

  void captureDebugPrintLine(
    String message, {
    String component = 'Flutter',
  }) {
    if (_looksLikeStructuredAppLogLine(message)) return;
    record(
      component: component,
      level: AppLogLevel.info,
      message: message,
    );
  }

  void clear() {
    if (_entries.isEmpty) return;
    _entries.clear();
    notifyListeners();
  }

  void _append(AppLogEntry appLogEntry) {
    _entries.add(appLogEntry);
    _trimOldEntriesIfNeeded();
    notifyListeners();
  }

  void _trimOldEntriesIfNeeded() {
    if (_entries.length <= maxEntries) return;
    final overflowEntryCount = _entries.length - maxEntries;
    _entries.removeRange(0, overflowEntryCount);
  }

  bool _looksLikeStructuredAppLogLine(String message) =>
      RegExp(r'^\[\d{2}:\d{2}:\d{2}\.\d{2}\|').hasMatch(message);
}

final appLogBuffer = AppLogBuffer();
