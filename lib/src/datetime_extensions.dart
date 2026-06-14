/// Extensions on DateTime.
extension DateTimeExtensions on DateTime {
  /// Check if same calendar day as another date.
  bool sameDayAs(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Check if this date is today.
  bool get isToday => sameDayAs(DateTime.now());

  /// Milliseconds since epoch as double.
  double get millisSinceEpoch => millisecondsSinceEpoch.toDouble();

  /// Start of day (midnight).
  DateTime get startOfDay => DateTime(year, month, day);

  /// End of day (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Midnight of the calendar day [days] away from this date.
  ///
  /// Shifts via the `DateTime` constructor rather than `Duration(days:)` so
  /// daylight-saving transitions never push the result off local midnight.
  /// The time component is always dropped, so the result is comparable with
  /// other midnight-keyed dates.
  DateTime shiftedByDays(int days) => DateTime(year, month, day + days);
}
