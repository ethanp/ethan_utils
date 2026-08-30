import 'package:flutter/material.dart';

import 'string_extensions.dart';

/// Extensions on Color.
extension ColorExtensions on Color? {
  /// Lerp between this color and another.
  Color lerpWith(Color? other, double t) => Color.lerp(this, other, t)!;
}

/// Distinct shade of a base color keyed by an opaque seed string.
extension ColorShadeKeyedBy on Color {
  /// Same hue family; lightness/saturation nudged from [seed]'s [stableHash].
  Color shadeKeyedBy(String seed) {
    final hsl = HSLColor.fromColor(this);
    final shadeSeed = seed.stableHash;
    final lightnessStep = (shadeSeed % 5) - 2;
    final saturationStep = ((shadeSeed ~/ 5) % 3) - 1;
    final lightness = (hsl.lightness + lightnessStep * 0.08).clamp(0.32, 0.78);
    final saturation = (hsl.saturation + saturationStep * 0.08).clamp(
      0.42,
      0.95,
    );
    return hsl.withLightness(lightness).withSaturation(saturation).toColor();
  }
}
