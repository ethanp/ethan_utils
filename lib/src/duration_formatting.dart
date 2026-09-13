/// Formatting helpers for [Duration] UI labels.
extension DurationFormatting on Duration {
  /// Whole seconds with unit: `3s`, `125s`.
  String get formattedSeconds => '${abs().inSeconds}s';

  /// Compact elapsed span: `m:ss`, then `h:mm:ss` (leading fields unpadded).
  String get formattedElapsed =>
      abs()._colonHms(padMinutes: false, padHours: false);

  /// Digital timer face: `mm:ss`, or `HH:mm:ss` when ≥ 1 hour.
  String get formattedClock =>
      abs()._colonHms(padMinutes: true, padHours: true);

  /// Media length/position as total minutes: `m:ss` (minutes may exceed 59).
  String get formattedMinutesSeconds {
    final duration = abs();
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inMinutes}:$seconds';
  }

  /// Spoken-style span: `5m 30s`, or `1h 02m 30s` when ≥ 1 hour.
  String get formattedHms {
    final duration = abs();
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${_twoDigits(minutes)}m ${_twoDigits(seconds)}s';
    }
    return '${minutes}m ${_twoDigits(seconds)}s';
  }

  /// Like [formattedHms] but drops seconds when ≥ 1 hour: `1h 02m`.
  String get formattedHm {
    final duration = abs();
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) return '${hours}h ${_twoDigits(minutes)}m';
    return '${minutes}m ${_twoDigits(seconds)}s';
  }

  /// Interval style: `45s`, or `2m 30s` when ≥ 1 minute.
  String get formattedMinutesOrSeconds {
    final duration = abs();
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _colonHms({required bool padMinutes, required bool padHours}) {
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    if (inHours < 1) {
      final minutes = padMinutes
          ? inMinutes.toString().padLeft(2, '0')
          : '$inMinutes';
      return '$minutes:$seconds';
    }
    final hours = padHours ? inHours.toString().padLeft(2, '0') : '$inHours';
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
