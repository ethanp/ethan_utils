import 'string_extensions.dart';

/// Extensions on Enum.
extension EnumExtensions on Enum {
  String get nameAsCapitalizedWords => name.camelToTitleCase;
}
