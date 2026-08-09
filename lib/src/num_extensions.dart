import 'dart:math' as math;

/// Extensions on num.
extension NumExtensions on num {
  /// Convert degrees to radians.
  double get deg2rad => this * math.pi / 180;

  /// Convert radians to degrees.
  double get rad2deg => this * 180 / math.pi;

  /// Classic chart step: 1 / 2 / 5 × 10^n.
  ///
  /// When [round] is true, snaps to a nearby nice value (axis steps).
  /// When false, ceilings toward the next nice value (bounds).
  double niceNumber({bool round = true}) {
    if (this <= 0) return 1;
    final exponent = (math.log(this) / math.ln10).floor();
    final fraction = this / math.pow(10, exponent);
    late final double niceFraction;
    if (round) {
      if (fraction < 1.5) {
        niceFraction = 1;
      } else if (fraction < 3) {
        niceFraction = 2;
      } else if (fraction < 7) {
        niceFraction = 5;
      } else {
        niceFraction = 10;
      }
    } else if (fraction <= 1) {
      niceFraction = 1;
    } else if (fraction <= 2) {
      niceFraction = 2;
    } else if (fraction <= 5) {
      niceFraction = 5;
    } else {
      niceFraction = 10;
    }
    return niceFraction * math.pow(10, exponent);
  }

  /// Compact count label: `324`, `1k`, `1.2k`, `3.4M`.
  String get asCompactCount {
    final sign = this < 0 ? '-' : '';
    final absolute = abs();
    if (absolute >= 1000000) {
      return '$sign${_compactCoefficient(absolute / 1000000)}M';
    }
    if (absolute >= 1000) {
      return '$sign${_compactCoefficient(absolute / 1000)}k';
    }
    if (this == roundToDouble()) return '${toInt()}';
    return toString();
  }
}

/// One-decimal coefficient for k/M suffixes (`1`, `1.2`).
String _compactCoefficient(num scaled) {
  if ((scaled - scaled.round()).abs() < 0.001) return '${scaled.round()}';
  final oneDecimal = (scaled * 10).round() / 10;
  if ((oneDecimal * 10).round() % 10 == 0) return '${oneDecimal.round()}';
  return oneDecimal.toStringAsFixed(1);
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
