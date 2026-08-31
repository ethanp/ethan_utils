import 'package:flutter/painting.dart';

/// Width after [TextPainter.layout], not a character count.
extension StringLaidOutWidth on String {
  double laidOutWidth(TextStyle style, {int maxLines = 1}) {
    final textPainter = TextPainter(
      text: TextSpan(text: this, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    )..layout();
    return textPainter.width;
  }
}

/// Widest [laidOutWidth] among the strings.
extension StringsWidestLaidOutWidth on Iterable<String> {
  double widestLaidOutWidth(TextStyle style, {int maxLines = 1}) {
    var widest = 0.0;
    for (final text in this) {
      final width = text.laidOutWidth(style, maxLines: maxLines);
      if (width > widest) widest = width;
    }
    return widest;
  }
}
