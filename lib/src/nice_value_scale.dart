import 'num_extensions.dart';

/// Y-axis (or similar) scale snapped to human-readable 1 / 2 / 5 × 10^n ticks.
class const NiceValueScale({
  /// Inclusive upper bound of the scale (a nice multiple of the tick step).
  required final double max,

  /// Tick values from 0 through [max], inclusive.
  required final List<double> ticks,
}) {
  /// Builds a scale that covers [dataMax] with about [targetTickCount] steps.
  ///
  /// When [dataMax] is ≤ 0, uses [fallbackMax] instead.
  factory forMax(
    double dataMax, {
    int targetTickCount = 4,
    double fallbackMax = 1,
  }) {
    final positiveMax = dataMax > 0 ? dataMax : fallbackMax;
    final step = (positiveMax / targetTickCount).niceNumber(round: true);
    final niceMax = (positiveMax / step).ceil() * step;
    final ticks = <double>[];
    for (var tick = 0.0; tick <= niceMax + step * 0.001; tick += step) {
      ticks.add(tick);
    }
    return NiceValueScale(max: niceMax, ticks: ticks);
  }
}
