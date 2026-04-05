import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_log_buffer.dart';

typedef FlutterErrorCapturePredicate = bool Function(
  FlutterErrorDetails details,
);

DebugPrintCallback? _originalDebugPrintCallback;
FlutterExceptionHandler? _originalFlutterExceptionHandler;
bool _debugPrintCaptureInstalled = false;
bool _flutterErrorCaptureInstalled = false;

void installAppLogCapture({
  bool captureDebugPrint = true,
  FlutterErrorCapturePredicate? shouldCaptureFlutterError,
}) {
  _installFlutterErrorCapture(
    shouldCaptureFlutterError: shouldCaptureFlutterError,
  );
  if (captureDebugPrint) {
    _installDebugPrintCapture();
  }
}

void runWithAppLogZone(
  void Function() appRunner, {
  bool capturePrintCalls = true,
}) {
  final logZoneSpecification = capturePrintCalls
      ? ZoneSpecification(
          print: (zoneSelf, zoneDelegate, zone, line) {
            appLogBuffer.capturePrintLine(line);
            zoneDelegate.print(zone, line);
          },
        )
      : null;

  runZonedGuarded(
    appRunner,
    (error, stackTrace) {
      appLogBuffer.record(
        component: 'Zone',
        level: AppLogLevel.error,
        message: 'Uncaught async error',
        error: error,
        stackTrace: stackTrace,
      );
    },
    zoneSpecification: logZoneSpecification,
  );
}

void _installFlutterErrorCapture({
  FlutterErrorCapturePredicate? shouldCaptureFlutterError,
}) {
  if (_flutterErrorCaptureInstalled) return;
  _originalFlutterExceptionHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    final shouldCapture = shouldCaptureFlutterError?.call(details) ?? true;
    if (!shouldCapture) {
      _originalFlutterExceptionHandler?.call(details);
      return;
    }
    appLogBuffer.record(
      component: 'FlutterError',
      level: AppLogLevel.error,
      message: details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
    _originalFlutterExceptionHandler?.call(details);
  };
  _flutterErrorCaptureInstalled = true;
}

void _installDebugPrintCapture() {
  if (_debugPrintCaptureInstalled) return;
  _originalDebugPrintCallback = debugPrint;
  debugPrint = (message, {wrapWidth}) {
    if (message != null && message.isNotEmpty) {
      appLogBuffer.captureDebugPrintLine(message);
    }
    _originalDebugPrintCallback?.call(message, wrapWidth: wrapWidth);
  };
  _debugPrintCaptureInstalled = true;
}
