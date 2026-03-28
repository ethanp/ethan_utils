/// Extensions on String.
extension StringExtensions on String {
  static final _upperCase = RegExp(r'([A-Z])');

  /// Capitalize the first character.
  String get capitalize =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);

  /// Convert "title case" to "Title Case" (viz. capitalize each word).
  String get titleCase => split(' ').map((word) => word.capitalize).join(' ');

  /// Convert camelCase to snake_case.
  String get snakeCase => replaceAllMapped(
        _upperCase,
        (match) => '_${match.group(0)!.toLowerCase()}',
      );

  /// Convert camelCase to Title Case (e.g. `injuryHistory` -> `Injury History`).
  String get camelToTitleCase =>
      replaceAllMapped(_upperCase, (m) => ' ${m.group(0)}').trim().titleCase;
}
