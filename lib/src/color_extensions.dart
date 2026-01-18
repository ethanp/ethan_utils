import 'package:flutter/material.dart';

/// Extensions on Color.
extension ColorExtensions on Color? {
  /// Lerp between this color and another.
  Color lerpWith(Color? other, double t) => Color.lerp(this, other, t)!;
}
