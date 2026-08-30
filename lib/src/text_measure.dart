import 'package:flutter/painting.dart';

/// Painted text width via [TextPainter].
extension TextPaintMeasure on String {
  double measureWidth(TextStyle style, {int maxLines = 1}) {
    final textPainter = TextPainter(
      text: TextSpan(text: this, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    )..layout();
    return textPainter.width;
  }
}

/// Widest painted width among strings.
extension TextsPaintMeasure on Iterable<String> {
  double maxPaintedWidth(TextStyle style, {int maxLines = 1}) {
    var widest = 0.0;
    for (final text in this) {
      final width = text.measureWidth(style, maxLines: maxLines);
      if (width > widest) widest = width;
    }
    return widest;
  }
}
