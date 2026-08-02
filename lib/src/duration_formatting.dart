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

  String _colonHms({
    required bool padMinutes,
    required bool padHours,
  }) {
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    if (inHours < 1) {
      final minutes =
          padMinutes ? inMinutes.toString().padLeft(2, '0') : '$inMinutes';
      return '$minutes:$seconds';
    }
    final hours = padHours ? inHours.toString().padLeft(2, '0') : '$inHours';
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
