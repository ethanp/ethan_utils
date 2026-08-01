/// Formatting helpers for [Duration] UI labels.
extension DurationFormatting on Duration {
  /// Whole seconds with unit: `3s`, `125s`.
  String get formattedSeconds => '${abs().inSeconds}s';

  /// Compact elapsed span: `m:ss`, then `h:mm:ss` (leading fields unpadded).
  String get formattedElapsed =>
      _colonHms(abs(), padMinutes: false, padHours: false);

  /// Digital timer face: `mm:ss`, or `HH:mm:ss` when ≥ 1 hour.
  String get formattedClock =>
      _colonHms(abs(), padMinutes: true, padHours: true);

  /// Media length/position as total minutes: `m:ss` (minutes may exceed 59).
  String get formattedMinutesSeconds {
    final duration = abs();
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inMinutes}:$seconds';
  }
}

String _colonHms(
  Duration duration, {
  required bool padMinutes,
  required bool padHours,
}) {
  final seconds =
      duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (duration.inHours < 1) {
    final minutes = padMinutes
        ? duration.inMinutes.toString().padLeft(2, '0')
        : '${duration.inMinutes}';
    return '$minutes:$seconds';
  }
  final hours = padHours
      ? duration.inHours.toString().padLeft(2, '0')
      : '${duration.inHours}';
  final minutes =
      duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
