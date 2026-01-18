/// Extensions on String.
extension StringExtensions on String {
  /// Capitalize the first character.
  String get capitalize =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);

  /// Convert to title case (capitalize each word).
  String get titleCase =>
      split(' ').map((word) => word.capitalize).join(' ');
}
