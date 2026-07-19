/// Parsing helpers for dynamic SQLite / JSON column values.
///
/// Call sites must have a static type of [Object?] (not [dynamic]) so the
/// extension applies — e.g. `map.cast<String, Object?>()` or `value as Object?`.
extension DynamicIntParsing on Object? {
  /// Coerces to [int]. Throws if null or not a number-like value.
  int asInt() {
    if (this is int) return this as int;
    if (this is num) return (this as num).toInt();
    if (this == null) {
      throw ArgumentError('Expected int, got null');
    }
    return int.parse('$this');
  }

  /// Coerces to [int], or null if this is null / not parsable.
  int? asIntOrNull() {
    if (this == null) return null;
    if (this is int) return this as int;
    if (this is num) return (this as num).toInt();
    return int.tryParse('$this');
  }
}
