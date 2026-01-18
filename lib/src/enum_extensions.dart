import 'string_extensions.dart';

/// Extensions on Enum.
extension EnumExtensions on Enum {
  static final _isCapital = RegExp(r'([A-Z])');

  /// Convert camelCase enum name to "Capitalized Words".
  String get nameAsCapitalizedWords => name
      .replaceAllMapped(_isCapital, (match) => ' ${match.group(0)}')
      .trim()
      .capitalize;
}
