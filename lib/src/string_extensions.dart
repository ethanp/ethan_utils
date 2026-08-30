/// Extensions on String.
extension StringExtensions on String {
  static final _upperCase = RegExp(r'([A-Z])');

  /// Stable non-negative hash for palette / shade seeding.
  int get stableHash {
    var hash = 0;
    for (final codeUnit in codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  /// Parses a decimal amount string (`-12.34`) into integer cents.
  int get asCents {
    final trimmed = trim();
    if (trimmed.isEmpty) return 0;
    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      throw FormatException('Invalid amount: $this');
    }
    return (parsed * 100).round();
  }

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
