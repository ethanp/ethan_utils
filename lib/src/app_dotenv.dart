import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'logger.dart';

const _log = ELogger('AppDotEnv');

/// Loads the app `.env` asset (optional by default).
///
/// Apps should declare `.env` under `flutter.assets` and keep the real file
/// gitignored, with a committed `.env.example`.
Future<void> loadAppDotEnv({
  String fileName = '.env',
  bool isOptional = true,
}) async {
  try {
    await dotenv.load(fileName: fileName, isOptional: isOptional);
  } catch (error, stackTrace) {
    _log.error('Failed to load $fileName', error, stackTrace);
    if (!isOptional) rethrow;
  }
}

/// Trimmed non-empty env value, or null.
String? envString(String key) {
  if (!dotenv.isInitialized) return null;
  final value = dotenv.env[key]?.trim();
  if (value == null || value.isEmpty) return null;
  return value;
}

String envStringOr(String key, String fallback) => envString(key) ?? fallback;

int envIntOr(String key, int fallback) {
  final raw = envString(key);
  if (raw == null) return fallback;
  return int.tryParse(raw) ?? fallback;
}
