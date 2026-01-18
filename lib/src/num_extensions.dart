import 'dart:math' as math;

/// Extensions on num.
extension NumExtensions on num {
  /// Convert degrees to radians.
  double get deg2rad => this * math.pi / 180;

  /// Convert radians to degrees.
  double get rad2deg => this * 180 / math.pi;
}

/// Extensions on int.
extension IntExtensions on int {
  /// Pad with leading zeros.
  String pad(int width) => toString().padLeft(width, '0');

  /// Format minutes as hours component.
  String get hours => (this ~/ 60).pad(1);

  /// Format minutes as minutes component (2 digits).
  String get minutes => (this % 60).pad(2);

  /// Format total minutes as HH:MM.
  String get minsToHhMm => '$hours:$minutes';
}
